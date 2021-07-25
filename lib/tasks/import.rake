# frozen_string_literal: true

require "csv"
require "activerecord-import"

$LOAD_PATH << File.join(__dir__, "..", "..", "app")

require "models/stop_location"
require "models/scan"

namespace :import do
  desc "import:stop_locations"
  task stop_locations: :environment do
    start_location_count = StopLocation.count
    StopLocation
      .read_file_in_batches("data/myki/stop_locations.txt.gz")
      .then { StopLocation.ar_insert_all(_1) }
    puts format "added %<locations>s stop locations", locations: StopLocation.count - start_location_count
  end

  desc "import:scan_data"
  task scan_data: :environment do
    Dir["data/myki/full_samp_0_and_1/**/*.txt.gz"]
      .map do |filename|
        next unless Scan.where(source: filename[%r{[^/]+.txt.gz}]).count.zero?

        Scan
          .read_file_in_batches(filename)
          .map { Scan.enrich_scan_and_source(filename, _1) }
          .then { Scan.ar_insert_all(_1) }
      end
  end

  desc "import:clean_stop_locations"
  task clean_stop_locations: :environment do
    puts format "deleted %<locations>s stop locations", locations: StopLocation.delete_all
  end
end
