# frozen_string_literal: true

class IdempotencyKey < ApplicationRecord
  belongs_to :bank_account

  validates :key, presence: true, uniqueness: { scope: :bank_account_id }
end
