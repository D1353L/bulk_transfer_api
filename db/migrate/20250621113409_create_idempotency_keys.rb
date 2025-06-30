# frozen_string_literal: true

class CreateIdempotencyKeys < ActiveRecord::Migration[8.0]
  def change
    create_table :idempotency_keys do |t|
      t.string :key, null: false
      t.timestamps

      t.references :bank_account, foreign_key: true
    end

    add_index :idempotency_keys, %i[key bank_account_id], unique: true,
                                                          name: 'index_idempotency_keys_on_key_and_bank_account_id'
  end
end
