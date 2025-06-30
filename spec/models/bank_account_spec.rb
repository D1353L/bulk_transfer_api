# frozen_string_literal: true

require 'rails_helper'

RSpec.describe BankAccount, type: :model do
  subject { build(:bank_account) }

  describe 'associations' do
    it { is_expected.to have_many(:transactions).dependent(:restrict_with_error) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:organization_name) }
    it { is_expected.to validate_presence_of(:balance_cents) }
    it { is_expected.to validate_presence_of(:iban) }
    it { is_expected.to validate_presence_of(:bic) }

    it { is_expected.to validate_uniqueness_of(:iban) }

    it { is_expected.to validate_numericality_of(:balance_cents).is_greater_than_or_equal_to(0) }
  end

  describe 'dependent restriction' do
    let(:bank_account) { create(:bank_account) }
    let(:transaction) { create(:transaction, bank_account: bank_account) }

    it 'prevents deletion if dependent transactions exist' do
      transaction
      expect { bank_account.destroy }.not_to change(described_class, :count)
      expect(bank_account.errors[:base]).to include('Cannot delete record because dependent transactions exist')
    end
  end
end
