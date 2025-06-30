# frozen_string_literal: true

FactoryBot.define do
  factory :transaction do
    counterparty_name { 'Bip Bip' }
    counterparty_iban { 'EE383680981021245685' }
    counterparty_bic { 'CRLYFRPPTOU' }
    amount_cents { -1_000_000 }
    amount_currency { 'EUR' }
    description { 'Bip Bip Salary' }
    association :bank_account
  end
end
