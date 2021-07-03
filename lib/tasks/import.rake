# frozen_string_literal: true

require "csv"

def filename_and_scan(scan_filename)
  {
    filename: scan_filename,
    scan: scan_filename[/Scan(On|Off)Transaction/, 1].downcase,
    source: scan_filename[%r{[^/]+.txt.gz}]
  }
end

namespace :import do
  desc "import:stop_locations"
  task stop_locations: :environment do
    fields = %w[id street location type suburb postcode city council areas latitide longitude]
    Zlib::GzipReader
      .open("data/myki/stop_locations.txt.gz", &:readlines)
      .map { |l| CSV.parse(l, col_sep: "|")[0] }
      .each_slice(1000)
      .map { |batch_line| batch_line.map { |line| fields.zip(line).to_h } }
      .then { puts _1 }
  end

  desc "import:stop_locations"
  task scan_data: :environment do
    fields = %w[mode businessdate date_time card_id card_type vehicle_id parent_route route_id stop_id]
    Dir["data/myki/full_samp_0_and_1/**/*.txt.gz"]
      .map { filename_and_scan _1 }
      .map do |args|
      Zlib::GzipReader
        .open(args[:filename], &:readlines)
        .map { |l| CSV.parse(l, col_sep: "|")[0] }
        .first(10) # NOTE: currently just a limit of first 10 batches
        .each_slice(1000)
        .map { |batch_line| batch_line.map { |line| fields.zip(line).to_h.merge(args.slice(:scan, :source)) } }
        .then { puts _1 }
    end
  end
end
