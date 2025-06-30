# frozen_string_literal: true

require 'rails_helper'

RSpec.describe BulkTransferService do
  subject(:service) do
    described_class.new(sender_bic: sender_bic, sender_iban: sender_iban, credit_transfers: credit_transfers)
  end

  let(:sender_bic) { 'SENDERBIC123' }
  let(:sender_iban) { 'SENDERIBAN123' }
  let!(:bank_account) { create(:bank_account, bic: sender_bic, iban: sender_iban, balance_cents: 10_000) }
  let(:credit_transfers_mapper_mock) { instance_spy(CreditTransfersMapper) }

  let(:credit_transfers) do
    [
      {
        amount: '50.12',
        currency: 'USD',
        counterparty_name: 'Alice',
        counterparty_iban: 'ALICEIBAN',
        counterparty_bic: 'ALICEBIC',
        description: 'Payment'
      },
      {
        amount: '30.8',
        currency: 'USD',
        counterparty_name: 'Bob',
        counterparty_iban: 'BOBIBAN',
        counterparty_bic: 'BOBBIC',
        description: 'Invoice'
      },
      {
        amount: '9',
        currency: 'USD',
        counterparty_name: 'Bob2',
        counterparty_iban: 'BOBIBAN2',
        counterparty_bic: 'BOBBIC2',
        description: 'Invoice'
      }
    ]
  end

  let(:transactions) do
    credit_transfers.map do |ct|
      build(:transaction,
            counterparty_name: ct[:counterparty_name],
            counterparty_iban: ct[:counterparty_iban],
            counterparty_bic: ct[:counterparty_bic],
            amount_cents: -(BigDecimal(ct[:amount]) * 100).to_i,
            amount_currency: ct[:currency],
            description: ct[:description],
            bank_account: bank_account,
            created_at: Time.zone.now,
            updated_at: Time.zone.now)
    end
  end

  before do
    allow(BankAccount).to receive(:lock).with('FOR UPDATE') do
      class_double(BankAccount, find_by: bank_account)
    end

    allow(CreditTransfersMapper).to receive(:new).and_return(credit_transfers_mapper_mock)
    allow(credit_transfers_mapper_mock).to receive(:call).and_return(transactions)
  end

  describe '#perform!' do
    it 'updates the bank account balance correctly' do
      expect { service.perform! }.to change { bank_account.reload.balance_cents }.by(-8_992)
    end

    it 'inserts transactions into the database' do
      expect do
        service.perform!
      end.to change(Transaction, :count).by(3)
    end

    it 'builds transactions from credit transfers' do
      service.perform!
      expect(credit_transfers_mapper_mock).to have_received(:call)
    end

    context 'when the bank account is not found' do
      before do
        allow(BankAccount).to receive(:lock).with('FOR UPDATE') do
          class_double(BankAccount, find_by: nil)
        end
      end

      it 'raises BankAccountNotFound error' do
        expect { service.perform! }.to raise_error(BulkTransferService::BankAccountNotFound)
      end
    end

    context 'when the bank account is locked by another process' do
      before do
        statement_timeout = ActiveRecord::StatementTimeout.new('Timeout')
        allow(statement_timeout).to receive(:cause).and_return(SQLite3::BusyException.new('busy'))

        allow(BankAccount).to receive(:lock).and_raise(statement_timeout)
      end

      it 'raises BankAccountLocked error' do
        expect { service.perform! }.to raise_error(BulkTransferService::BankAccountLocked)
      end
    end

    context 'when funds are insufficient' do
      before do
        bank_account.update!(balance_cents: 1_000)
      end

      it 'raises InsufficientFunds error' do
        expect { service.perform! }.to raise_error(BulkTransferService::InsufficientFunds)
      end
    end
  end
end
