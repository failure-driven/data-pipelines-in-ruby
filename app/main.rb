# frozen_string_literal: true

require "active_record"
require "activerecord-import/base"
require "activerecord-import/active_record/adapters/postgresql_adapter"
require "pry"
require "benchmark"

$LOAD_PATH << File.join(
  File.expand_path(__dir__)
)
require "models/stop_location"

def db_configuration
  db_configuration_file = File.join(
    File.expand_path(__dir__), "..", "db", "config.yml"
  )
  YAML.load(File.read(db_configuration_file)) # rubocop:disable Security/YAMLLoad
end

ActiveRecord::Base.establish_connection(
  db_configuration["development"]
)

# record_limit = ARGV[0].to_i
# record_limit = 1_000 if record_limit.zero?

# puts "running test on #{record_limit} records"

# make
#   bundle exec ruby app/main.rb ${RECORD_COUNT}
#
# user     system      total        real
# COPY AR ONE BY ONE   5.897386   0.533079   6.430465 (  8.858250)
#     COPY AR IMPORT   1.716771   0.013001   1.729772 (  2.236956)
# COPY AR INSERT_ALL   1.282491   0.005851   1.288342 (  1.565381)

Benchmark.bm(20) do |x|
  StopLocation.delete_all
  x.report(format("%20s", "COPY AR ONE BY ONE")) do
    raise "locations not empty" unless StopLocation.count.zero?

    StopLocation
      .read_file_in_batches("data/myki/stop_locations.txt.gz")
      .then { StopLocation.ar_one_by_one(_1) }
    raise "locations not all loaded" unless StopLocation.count == 27_614
  end

  StopLocation.delete_all
  x.report(format("%20s", "COPY AR IMPORT")) do
    raise "locations not empty" unless StopLocation.count.zero?

    StopLocation
      .read_file_in_batches("data/myki/stop_locations.txt.gz")
      .then { StopLocation.ar_import(_1) }
    raise "locations not all loaded" unless StopLocation.count == 27_614
  end

  StopLocation.delete_all
  x.report(format("%20s", "COPY AR INSERT_ALL")) do
    raise "locations not empty" unless StopLocation.count.zero?

    StopLocation
      .read_file_in_batches("data/myki/stop_locations.txt.gz")
      .then { StopLocation.ar_insert_all(_1) }
    raise "locations not all loaded" unless StopLocation.count == 27_614
  end
end
