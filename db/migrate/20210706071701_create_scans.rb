# frozen_string_literal: true

class CreateScans < ActiveRecord::Migration[6.0]
  def change
    create_table :scans do |t|
      t.text :mode, null: false
      t.date :business_date, null: false
      t.datetime :date_time, null: false
      t.text :card_id, null: false
      t.text :card_type, null: false
      t.text :vehicle_id, null: false
      t.text :parent_route
      t.text :route_id, null: false
      t.bigint :stop_id, null: false
      t.boolean :scan_on, null: false
      t.text :source, null: false
    end
  end
end
