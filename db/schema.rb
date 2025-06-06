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

ActiveRecord::Schema[8.0].define(version: 2025_06_06_002934) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "item_versions", force: :cascade do |t|
    t.bigint "item_id", null: false
    t.string "name", null: false
    t.text "description", default: "", null: false
    t.string "condition", default: "good", null: false
    t.integer "daily_price", default: 1000, null: false
    t.string "availability_status", default: "unavailable", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["item_id"], name: "index_item_versions_on_item_id"
  end

  create_table "items", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_items_on_user_id"
  end

  create_table "rejected_rentals", force: :cascade do |t|
    t.bigint "rental_transaction_id", null: false
    t.datetime "rejected_at", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["rental_transaction_id"], name: "index_rejected_rentals_on_rental_transaction_id"
  end

  create_table "rental_transactions", force: :cascade do |t|
    t.bigint "lender_id", null: false
    t.bigint "borrower_id", null: false
    t.bigint "item_version_id", null: false
    t.date "starts_on", null: false
    t.date "ends_on", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["borrower_id", "item_version_id"], name: "index_rental_transactions_on_borrower_id_and_item_version_id", unique: true
    t.index ["item_version_id"], name: "index_rental_transactions_on_item_version_id"
    t.index ["lender_id"], name: "index_rental_transactions_on_lender_id"
  end

  create_table "requested_rentals", force: :cascade do |t|
    t.bigint "rental_transaction_id", null: false
    t.datetime "requested_at", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["rental_transaction_id"], name: "index_requested_rentals_on_rental_transaction_id", unique: true
  end

  create_table "user_profile_versions", force: :cascade do |t|
    t.bigint "user_profile_id", null: false
    t.string "address", null: false
    t.string "phone_number", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_profile_id"], name: "index_user_profile_versions_on_user_profile_id"
  end

  create_table "user_profiles", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_user_profiles_on_user_id", unique: true
  end

  create_table "users", force: :cascade do |t|
    t.string "name", null: false
    t.string "email", null: false
    t.string "google_uid", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["google_uid"], name: "index_users_on_google_uid", unique: true
  end

  add_foreign_key "item_versions", "items"
  add_foreign_key "items", "users"
  add_foreign_key "rejected_rentals", "rental_transactions"
  add_foreign_key "rental_transactions", "item_versions"
  add_foreign_key "rental_transactions", "users", column: "borrower_id"
  add_foreign_key "rental_transactions", "users", column: "lender_id"
  add_foreign_key "requested_rentals", "rental_transactions"
  add_foreign_key "user_profile_versions", "user_profiles"
  add_foreign_key "user_profiles", "users"
end
