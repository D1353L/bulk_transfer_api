# frozen_string_literal: true

require 'swagger_helper'

describe TransfersController, type: :request do
  path '/transfers/bulk_create' do
    post 'Creates multiple credit transfers in bulk' do
      tags 'Transfers'
      consumes 'application/json'
      produces 'application/json'

      parameter name: 'Idempotency-Key', in: :headers

      parameter name: :transfer, in: :body, schema: {
        type: :object,
        properties: {
          transfer: {
            type: :object,
            required: %w[organization_bic organization_iban credit_transfers],
            properties: {
              organization_bic: { type: :string, example: 'BANKBIC22' },
              organization_iban: { type: :string, example: 'DE89370400440532013000' },
              credit_transfers: {
                type: :array,
                items: {
                  type: :object,
                  required: %w[amount currency counterparty_name counterparty_bic counterparty_iban description],
                  properties: {
                    amount: { type: :string, example: '100.00' },
                    currency: { type: :string, example: 'EUR' },
                    counterparty_name: { type: :string, example: 'Alice Doe' },
                    counterparty_bic: { type: :string, example: 'BICCODEXXX' },
                    counterparty_iban: { type: :string, example: 'FR7630006000011234567890189' },
                    description: { type: :string, example: 'Invoice payment' }
                  }
                }
              }
            }
          }
        },
        required: ['transfer']
      }

      let(:transfer) do
        {
          transfer: {
            organization_bic: 'OIVUSCLQXXX',
            organization_iban: 'DE89370400440532013000',
            credit_transfers: [
              {
                amount: '100.00',
                currency: 'EUR',
                counterparty_name: 'Alice Doe',
                counterparty_bic: 'CCOPFRPPXXX',
                counterparty_iban: 'FR7630006000011234567890189',
                description: 'Invoice payment'
              }
            ]
          }
        }
      end

      response '204', 'Bulk transfer request created successfully' do
        before do
          create(:bank_account, bic: 'OIVUSCLQXXX', iban: 'DE89370400440532013000', balance_cents: 1_000_000)
        end

        run_test!
      end

      response '422', 'Unprocessable content' do
        let(:transfer) do
          {
            transfer: {
              organization_bic: '',
              organization_iban: '',
              credit_transfers: []
            }
          }
        end

        run_test!
      end

      response '404', 'Resource not found' do
        let(:transfer) do
          {
            transfer: {
              organization_bic: 'NOTFOUNDXXX',
              organization_iban: 'DE89370400440532013000',
              credit_transfers: [
                {
                  amount: '100.00',
                  currency: 'EUR',
                  counterparty_name: 'Alice Doe',
                  counterparty_bic: 'CCOPFRPPXXX',
                  counterparty_iban: 'FR7630006000011234567890189',
                  description: 'Invoice payment'
                }
              ]
            }
          }
        end

        run_test!
      end

      response '423', 'Resource locked' do
        let(:bulk_transfer_api_mock) { instance_double(BulkTransferService) }

        before do
          allow(BulkTransferService).to receive(:new).and_return(bulk_transfer_api_mock)
          allow(bulk_transfer_api_mock).to receive(:perform!)
            .and_raise(BulkTransferService::BankAccountLocked,
                       'Bank account is locked by another process. Please try again later.')
        end

        run_test!
      end

      response '500', 'Unexpected error' do
        let(:bulk_transfer_api_mock) { instance_double(BulkTransferService) }

        before do
          allow(BulkTransferService).to receive(:new).and_return(bulk_transfer_api_mock)
          allow(bulk_transfer_api_mock).to receive(:perform!).and_raise(StandardError, 'Unexpected error')
        end

        run_test!
      end
    end
  end
end
