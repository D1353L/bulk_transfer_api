# frozen_string_literal: true

Schemas::BulkTransferCreate = Dry::Schema.Params do
  config.validate_keys = true

  required(:organization_bic).filled(:str?, format?: Constants::Regex::BIC_INPUT)
  required(:organization_iban).filled(:str?, format?: Constants::Regex::IBAN_INPUT)
  required(:credit_transfers).value(:array, min_size?: 1).each do
    hash do
      required(:amount).filled(:str?, format?: Constants::Regex::TRANSFER_AMOUNT_INPUT)
      required(:currency).filled(:str?, included_in?: ['EUR'])
      required(:counterparty_name).filled(:str?, max_size?: 70)
      required(:counterparty_bic).filled(:string, format?: Constants::Regex::BIC_INPUT)
      required(:counterparty_iban).filled(:string, format?: Constants::Regex::IBAN_INPUT)
      required(:description).filled(:str?, max_size?: 140)
    end
  end
end
