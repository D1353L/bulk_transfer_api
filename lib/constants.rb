# frozen_string_literal: true

module Constants
  module Regex
    TRANSFER_AMOUNT_INPUT = /^\d+(\.\d{1,2})?$/
    BIC_INPUT = /^[A-Z]{6}[A-Z0-9]{2}([A-Z0-9]{3})?$/
    IBAN_INPUT = /^[A-Z]{2}[0-9]{2}[A-Z0-9]{1,30}$/
  end
end
