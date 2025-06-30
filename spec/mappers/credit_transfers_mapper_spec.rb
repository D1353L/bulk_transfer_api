# frozen_string_literal: true

# spec/mappers/credit_transfers_mapper_mapper_spec.rb
require 'rails_helper'

RSpec.describe CreditTransfersMapper do
  let(:bank_account) { create(:bank_account) }

  let(:valid_credit_transfers) do
    [
      {
        counterparty_name: 'Alice',
        counterparty_iban: 'ALICEIBAN123',
        counterparty_bic: 'ALICEBIC',
        amount: '100.50',
        currency: 'USD',
        description: 'Payment for service'
      },
      {
        counterparty_name: 'Bob',
        counterparty_iban: 'BOBIBAN456',
        counterparty_bic: 'BOBBIC',
        amount: '200.00',
        currency: 'USD',
        description: 'Invoice payment'
      }
    ]
  end

  let(:mapper) { described_class.new(credit_transfers: valid_credit_transfers, bank_account: bank_account) }

  describe '#call' do
    it 'returns an array of validated Transaction instances' do
      transactions = mapper.call

      expect(transactions).to all(be_a(Transaction))
      expect(transactions.size).to eq(valid_credit_transfers.size)
      transactions.each(&:validate!) # should not raise

      # Check attributes of first transaction
      tx = transactions.first
      raw = valid_credit_transfers.first

      expect(tx.counterparty_name).to eq(raw[:counterparty_name])
      expect(tx.counterparty_iban).to eq(raw[:counterparty_iban])
      expect(tx.counterparty_bic).to eq(raw[:counterparty_bic])
      expect(tx.amount_cents).to eq(-(BigDecimal(raw[:amount]) * 100).to_i)
      expect(tx.amount_currency).to eq(raw[:currency])
      expect(tx.description).to eq(raw[:description])
      expect(tx.bank_account).to eq(bank_account)
      expect(tx.created_at).to be_within(1.second).of(Time.zone.now)
      expect(tx.updated_at).to be_within(1.second).of(Time.zone.now)
    end

    context 'when a transaction is invalid' do
      let(:mapper) { described_class.new(credit_transfers: invalid_credit_transfers, bank_account: bank_account) }

      let(:invalid_credit_transfers) do
        [
          {
            counterparty_name: nil, # missing required field (assuming presence validation)
            counterparty_iban: 'INVALIDIBAN',
            counterparty_bic: 'BIC',
            amount: '50',
            currency: 'USD',
            description: 'Invalid transfer'
          }
        ]
      end

      it 'raises ActiveRecord::RecordInvalid' do
        expect { mapper.call }.to raise_error(ActiveRecord::RecordInvalid)
      end
    end
  end
end
