# frozen_string_literal: true

class CreateBankAccounts < ActiveRecord::Migration[8.0]
  def change
    create_table :bank_accounts do |t|
      t.string  :organization_name
      t.integer :balance_cents, null: false, default: 0
      t.string  :iban, null: false
      t.string  :bic

      t.timestamps
    end

    add_index :bank_accounts, :iban, unique: true
  end
end
