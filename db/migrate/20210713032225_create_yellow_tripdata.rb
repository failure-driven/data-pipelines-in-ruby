class CreateYellowTripdata < ActiveRecord::Migration[6.0]
  def change
    create_table :yellow_tripdata do |t|
      t.integer :vendorid
      t.datetime :tpep_pickup_datetime
      t.datetime :tpep_dropoff_datetime
      t.integer :passenger_count
      t.float :trip_distance
      t.text :ratecodeid
      t.text :store_and_fwd_flag
      t.integer :pulocationid
      t.integer :dolocationid
      t.float :payment_type
      t.float :fare_amount
      t.float :extra
      t.float :mta_tax
      t.float :tip_amount
      t.float :tolls_amount
      t.float :improvement_surcharge
      t.float :total_amount
      t.float :congestion_surcharge
    end
  end
end
