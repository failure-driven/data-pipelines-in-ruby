# frozen_string_literal: true

class CreateStopLocation < ActiveRecord::Migration[6.0]
  def change
    create_table :stop_locations do |t|
      t.text :street, null: false
      t.text :location, null: false
      t.text :stop_type
      t.text :suburb
      t.text :postcode
      t.text :city
      t.text :council
      t.text :areas
      t.decimal :latitude, precision: 10, scale: 6, default: 0
      t.decimal :longitude, precision: 10, scale: 6, default: 0
    end
  end
end
