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

ActiveRecord::Schema.define(version: 2021_07_05_234434) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

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

end
