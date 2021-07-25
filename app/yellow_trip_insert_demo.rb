# frozen_string_literal: true

require "active_record"
require "activerecord-import/base"
require "activerecord-import/active_record/adapters/postgresql_adapter"
require "pry"
require "benchmark"
require "rcsv"

$LOAD_PATH << File.join(
  File.expand_path(__dir__)
)
require "models/yellow_trip_datum"

def db_configuration
  db_configuration_file = File.join(
    File.expand_path(__dir__), "..", "db", "config.yml"
  )
  YAML.load(File.read(db_configuration_file)) # rubocop:disable Security/YAMLLoad
end

ActiveRecord::Base.establish_connection(
  db_configuration["development"]
)

record_limit = ARGV[0].to_i
record_limit = 1_000 if record_limit.zero?
require "csv"
headers = CSV.parse(
  File
    .open("data/nyc_yellow_tripdata/yellow_tripdata_2020-01.csv")
  .each_line.lazy.first
).first.map(&:downcase)
csv_records = Rcsv.parse(
  File
    .open("data/nyc_yellow_tripdata/yellow_tripdata_2020-01.csv")
    .each_line.lazy.first(record_limit).join("\n"),
)

# make insert_demo RECORD_COUNT=100_000
# bundle exec ruby app/yellow_trip_insert_demo.rb 100_000
#                            user     system      total        real
#   COPY AR ONE BY ONE  88.954556   9.500534  98.455090 (179.043694)
#       COPY AR IMPORT   7.695401   0.071555   7.766956 (  9.731619)
#   COPY AR INSERT_ALL   5.621505   0.141534   5.763039 (  7.887981)

Benchmark.bm(20) do |x|
  YellowTripDatum.delete_all
  x.report(format("%20s", "COPY AR ONE BY ONE")) do
    raise "yellow trip not empty" unless YellowTripDatum.count.zero?

    csv_records
      .map do |values|
        record = headers.zip(values).to_h
        YellowTripDatum.create(record)
      end
    raise "yellow trip not all loaded #{YellowTripDatum.count}" unless YellowTripDatum.count == record_limit - 1
  end

  YellowTripDatum.delete_all
  x.report(format("%20s", "COPY AR IMPORT")) do
    raise "yellow trip not empty" unless YellowTripDatum.count.zero?

    YellowTripDatum.import(headers, csv_records)

    raise "yellow trip not all loaded #{YellowTripDatum.count}" unless YellowTripDatum.count == record_limit - 1
  end

  YellowTripDatum.delete_all
  x.report(format("%20s", "COPY AR INSERT_ALL")) do
    raise "yellow trip not empty" unless YellowTripDatum.count.zero?

    records = csv_records.map{|csv_record| headers.zip(csv_record).to_h }
    YellowTripDatum.insert_all(records)

    raise "yellow trip not all loaded #{YellowTripDatum.count}" unless YellowTripDatum.count == record_limit - 1
  end
end
