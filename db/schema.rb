# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.0].define(version: 2025_06_21_113409) do
  create_table "bank_accounts", force: :cascade do |t|
    t.string "organization_name"
    t.integer "balance_cents", default: 0, null: false
    t.string "iban", null: false
    t.string "bic"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["iban"], name: "index_bank_accounts_on_iban", unique: true
  end

  create_table "idempotency_keys", force: :cascade do |t|
    t.string "key", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "bank_account_id"
    t.index ["bank_account_id"], name: "index_idempotency_keys_on_bank_account_id"
    t.index ["key", "bank_account_id"], name: "index_idempotency_keys_on_key_and_bank_account_id", unique: true
  end

  create_table "transactions", force: :cascade do |t|
    t.string "counterparty_name"
    t.string "counterparty_iban"
    t.string "counterparty_bic"
    t.integer "amount_cents", null: false
    t.string "amount_currency", null: false
    t.text "description"
    t.integer "bank_account_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["bank_account_id"], name: "index_transactions_on_bank_account_id"
  end

  add_foreign_key "idempotency_keys", "bank_accounts"
  add_foreign_key "transactions", "bank_accounts"
end
