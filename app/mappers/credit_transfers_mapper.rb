# frozen_string_literal: true

class CreditTransfersMapper
  def initialize(credit_transfers:, bank_account:)
    @credit_transfers = credit_transfers
    @bank_account = bank_account
  end

  def call
    @credit_transfers.map do |raw_hash|
      build_transaction(raw_hash).tap(&:validate!)
    end
  end

  private

  attr_reader :credit_transfers, :bank_account

  def build_transaction(raw_hash)
    Transaction.new(
      counterparty_name: raw_hash[:counterparty_name],
      counterparty_iban: raw_hash[:counterparty_iban],
      counterparty_bic: raw_hash[:counterparty_bic],
      amount_cents: -amount_to_cents(raw_hash[:amount]),
      amount_currency: raw_hash[:currency],
      description: raw_hash[:description],
      bank_account: bank_account,
      created_at: Time.zone.now,
      updated_at: Time.zone.now
    )
  end

  def amount_to_cents(amount)
    (BigDecimal(amount) * 100).to_i
  end
end
