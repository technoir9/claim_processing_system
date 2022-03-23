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

ActiveRecord::Schema.define(version: 2022_03_22_225256) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "claims", force: :cascade do |t|
    t.bigint "customer_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["customer_id"], name: "index_claims_on_customer_id"
  end

  create_table "customers", force: :cascade do |t|
    t.string "email"
    t.string "first_name"
    t.string "last_name"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "flights", force: :cascade do |t|
    t.string "departure_airport_code"
    t.string "arrival_airport_code"
    t.string "airline_code"
    t.string "flight_number"
    t.date "departure_date"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "claim_id"
    t.string "flight_identifier"
    t.index ["claim_id"], name: "index_flights_on_claim_id"
  end

  add_foreign_key "claims", "customers"
  add_foreign_key "flights", "claims"
end
