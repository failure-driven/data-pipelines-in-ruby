# frozen_string_literal: true

require "arrow"

table = Arrow::Table.load("data/nyc_yellow_tripdata/yellow_tripdata_2020-01.arrow")
# Process data in table
pp table
# pp table.columns
pp table.each_record.first
pp table.each_record.count
