# frozen_string_literal: true

# spec/models/idempotency_key_spec.rb
require 'rails_helper'

RSpec.describe IdempotencyKey, type: :model do
  subject(:instance) { build(:idempotency_key) }

  describe 'associations' do
    it { is_expected.to belong_to(:bank_account) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:key) }

    it 'validates uniqueness of key scoped to bank_account_id' do
      create(:idempotency_key, key: 'unique-key', bank_account: create(:bank_account))

      expect(instance).to validate_uniqueness_of(:key).scoped_to(:bank_account_id)
    end
  end
end
