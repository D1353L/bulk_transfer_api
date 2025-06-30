# frozen_string_literal: true

FactoryBot.define do
  factory :bank_account do
    organization_name { 'Test Org' }
    balance_cents { 1_000_000 }
    iban { 'FR10474608000002006107XXXXX' }
    bic { 'OIVUSCLQXXX' }
  end
end
