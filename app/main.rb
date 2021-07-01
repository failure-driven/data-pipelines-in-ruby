# frozen_string_literal: true

require "active_record"
require "activerecord-import/base"
require "activerecord-import/active_record/adapters/postgresql_adapter"
require "pry"
require "benchmark"

$LOAD_PATH << File.join(
  File.expand_path(__dir__)
)
require "models/datum"

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

puts "running test on #{record_limit} records"

Benchmark.bm(30) do |x|
  x.report(format("%30s", "COPY AR ONE BY ONE")) do
    puts "confirm empty"
    puts "copy_ar_one_by_one(record_limit)"
    puts "confirm created"
  end

  x.report(format("%30s", "COPY AR IMPORT")) do
    puts "confirm empty"
    puts "copy_ar_import(record_limit)"
    puts "confirm created"
  end

  x.report(format("%30s", "COPY AR INSERT_ALL")) do
    puts "confirm empty"
    puts "copy_ar_insert_all(record_limit)"
    puts "confirm created"
  end
end
