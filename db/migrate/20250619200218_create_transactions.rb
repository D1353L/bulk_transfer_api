# frozen_string_literal: true

class CreateTransactions < ActiveRecord::Migration[8.0]
  def change
    create_table :transactions do |t|
      t.string  :counterparty_name
      t.string  :counterparty_iban
      t.string  :counterparty_bic
      t.integer :amount_cents, null: false
      t.string :amount_currency, null: false
      t.text :description
      t.references :bank_account, foreign_key: true

      t.timestamps
    end
  end
end
