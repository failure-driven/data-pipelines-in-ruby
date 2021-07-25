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
    .each_line.lazy.first(record_limit).join("\n")
)

YellowTripDatum.delete_all
raise "yellow trip not empty" unless YellowTripDatum.count.zero?

records = csv_records.map { |csv_record| headers.zip(csv_record).to_h }
YellowTripDatum.insert_all(records)

raise "yellow trip not all loaded #{YellowTripDatum.count}" unless YellowTripDatum.count == record_limit - 1

# make upsert_demo RECORD_COUNT=100_000
# bundle exec ruby app/yellow_trip_upsert_demo.rb 100_000
#                            user     system      total        real
# UPDATE AR ONE BY ONE  64.017015   7.038598  71.055613 (135.149358)
# UPDATE AR ONE BY ONE  44.008374   4.369588  48.377962 ( 91.373436)
#
#     UPDATE AR IMPORT   2.243142   0.049097   2.292239 (  3.431110)
#
# UPDATE AR UPSERT_ALL   0.778194   0.069718   0.847912 (  2.055556)

Benchmark.bm(20) do |x|
  x.report(format("%20s", "UPDATE AR ONE BY ONE")) do
    raise "yellow trip not reset" unless YellowTripDatum.where(trip_distance: 666.66).count.zero?

    YellowTripDatum
      .all
      .map do |yellow_trip_datum|
        yellow_trip_datum.update(trip_distance: 666.66)
      end
    unless YellowTripDatum.where(trip_distance: 666.66).count == record_limit - 1
      raise "yellow trip not all updated #{YellowTripDatum.count}"
    end
  end

  x.report(format("%20s", "UPDATE AR IMPORT")) do
    raise "yellow trip not reset" unless YellowTripDatum.where(trip_distance: 777.77).count.zero?

    records = YellowTripDatum.pluck(:id, :trip_distance).map { |id, _trip_distance| [id, 777.77] }
    YellowTripDatum.import(
      %i[id trip_distance],
      records,
      on_duplicate_key_update: %i[
        id
        trip_distance
      ]
    )

    unless YellowTripDatum.where(trip_distance: 777.77).count == record_limit - 1
      raise "yellow trip not all updated #{YellowTripDatum.count}"
    end
  end

  x.report(format("%20s", "UPDATE AR UPSERT_ALL")) do
    raise "yellow trip not reset" unless YellowTripDatum.where(trip_distance: 888.88).count.zero?

    rows = YellowTripDatum.pluck(:id, :trip_distance).map { |id, _trip_distance| [id, 888.88] }
    records = rows.map { |row| %i[id trip_distance].zip(row).to_h }
    # YellowTripDatum.upsert_all(
    #  records,
    #  on_duplicate: :update
    # )

    # all_records_updated = YellowTripDatum.where(trip_distance: 888.88).count == record_limit - 1
    # raise "yellow trip not all updated #{YellowTripDatum.count}" unless all_records_updated
  end
end
