# frozen_string_literal: true

require 'benchmark'

class BulkTransferService
  class BankAccountNotFound < StandardError; end
  class BankAccountLocked < StandardError; end
  class InsufficientFunds < StandardError; end

  def initialize(sender_bic:, sender_iban:, credit_transfers:, idempotency_key: nil)
    @sender_bic = sender_bic
    @sender_iban = sender_iban
    @credit_transfers = credit_transfers
    @idempotency_key = idempotency_key
  end

  def perform!
    ActiveRecord::Base.transaction do
      find_and_lock_bank_account
      abort_if_idempotent_request
      save_idempotency_key
      build_transactions
      validate_sufficient_funds
      update_account_balance
      insert_transactions
    end
  end

  private

  attr_reader :idempotency_key, :sender_bic, :sender_iban, :bank_account, :credit_transfers, :transactions, :new_balance

  def find_and_lock_bank_account
    @bank_account = BankAccount.lock('FOR UPDATE').find_by(bic: sender_bic,
                                                           iban: sender_iban)

    raise BankAccountNotFound, 'Bank account not found' unless bank_account
  rescue ActiveRecord::StatementTimeout => e
    if e.cause.is_a?(SQLite3::BusyException)
      raise BankAccountLocked, 'Bank account is locked by another process. Please try again later.'
    end

    raise
  end

  def abort_if_idempotent_request
    return if idempotency_key.blank? || !IdempotencyKey.exists?(key: idempotency_key, bank_account: bank_account)

    Rails.logger.info('Idempotent request detected')

    raise ActiveRecord::Rollback
  end

  def save_idempotency_key
    return if idempotency_key.blank?

    IdempotencyKey.create!(key: idempotency_key, bank_account: bank_account)
  end

  def build_transactions
    @transactions = CreditTransfersMapper.new(credit_transfers: credit_transfers,
                                              bank_account: bank_account).call
  end

  def validate_sufficient_funds
    total_amount_cents = transactions.sum(&:amount_cents)
    @new_balance = bank_account.balance_cents + total_amount_cents

    raise InsufficientFunds, 'Insufficient funds for bulk transfer' if new_balance.negative?
  end

  def update_account_balance
    bank_account.update!(balance_cents: new_balance)
  end

  # rubocop:disable Rails/SkipsModelValidations
  def insert_transactions
    result = Transaction.insert_all!(transactions.map(&:attributes))

    Rails.logger.info("#{result.rows.count} transactions for bank_account id=#{bank_account.id} inserted with ids #{result.rows.join(', ')}")
  end
  # rubocop:enable Rails/SkipsModelValidations
end
