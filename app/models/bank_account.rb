# frozen_string_literal: true

class BankAccount < ApplicationRecord
  has_many :transactions, dependent: :restrict_with_error
  has_many :idempotency_keys, dependent: :destroy

  validates :organization_name, :balance_cents, :iban, :bic, presence: true
  validates :iban, uniqueness: true
  validates :balance_cents, numericality: { greater_than_or_equal_to: 0 }
end
