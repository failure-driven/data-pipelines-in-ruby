# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `rails
# db:schema:load`. When creating a new database, `rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2021_07_13_032225) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "scans", force: :cascade do |t|
    t.text "mode", null: false
    t.date "business_date", null: false
    t.datetime "date_time", null: false
    t.text "card_id", null: false
    t.text "card_type", null: false
    t.text "vehicle_id", null: false
    t.text "parent_route"
    t.text "route_id", null: false
    t.bigint "stop_id", null: false
    t.boolean "scan_on", null: false
    t.text "source", null: false
  end

  create_table "stop_locations", force: :cascade do |t|
    t.text "street", null: false
    t.text "location", null: false
    t.text "stop_type"
    t.text "suburb"
    t.text "postcode"
    t.text "city"
    t.text "council"
    t.text "areas"
    t.decimal "latitude", precision: 10, scale: 6, default: "0.0"
    t.decimal "longitude", precision: 10, scale: 6, default: "0.0"
  end

  create_table "yellow_trip_data", force: :cascade do |t|
    t.integer "vendorid"
    t.datetime "tpep_pickup_datetime"
    t.datetime "tpep_dropoff_datetime"
    t.integer "passenger_count"
    t.float "trip_distance"
    t.text "ratecodeid"
    t.text "store_and_fwd_flag"
    t.integer "pulocationid"
    t.integer "dolocationid"
    t.float "payment_type"
    t.float "fare_amount"
    t.float "extra"
    t.float "mta_tax"
    t.float "tip_amount"
    t.float "tolls_amount"
    t.float "improvement_surcharge"
    t.float "total_amount"
    t.float "congestion_surcharge"
  end

end
