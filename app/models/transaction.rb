# frozen_string_literal: true

class Transaction < ApplicationRecord
  belongs_to :bank_account

  validates :counterparty_name, :counterparty_iban, :counterparty_bic, :amount_currency, :description, presence: true
  validates :amount_cents, numericality: { other_than: 0 }
end
