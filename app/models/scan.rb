# frozen_string_literal: true

require "csv"

class Scan < ActiveRecord::Base
  FIELDS = %w[
    mode
    business_date
    date_time
    card_id
    card_type
    vehicle_id
    parent_route
    route_id
    stop_id
    scan_on
    source
  ].freeze

  class << self
    def read_file_in_batches(filename)
      Zlib::GzipReader
        .open(filename, &:readlines)
        .map { |line| CSV.parse(line, col_sep: "|")[0] }
        # .first(1000)
        .each_slice(1000)
    end

    def enrich_scan_and_source(scan_filename, data)
      data
        .map {
          _1 + [
            scan_filename[/Scan(On|Off)Transaction/, 1].downcase,
            scan_filename[%r{[^/]+.txt.gz}]
          ]
        }
    end

    def ar_insert_all(batch)
      batch
        .map { |batch_line| batch_line.map { |line| FIELDS.zip(line).to_h } }
        .map { |locations| Scan.insert_all(locations) }
    end
  end
end
