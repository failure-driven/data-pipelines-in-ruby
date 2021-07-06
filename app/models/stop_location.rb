# frozen_string_literal: true

require "csv"

class StopLocation < ActiveRecord::Base
  FIELDS = %w[id street location stop_type suburb postcode city council areas latitude longitude].freeze

  class << self
    def read_file_in_batches(filename)
      Zlib::GzipReader
        .open(filename, &:readlines)
        .map { |line| CSV.parse(line, col_sep: "|")[0] }
        .each_slice(1000)
    end

    def ar_import(batch)
      batch
        .map { |batch_line| StopLocation.import(FIELDS, batch_line) }
    end

    def ar_insert_all(batch)
      batch
        .map { |batch_line| batch_line.map { |line| FIELDS.zip(line).to_h } }
        .map { |locations| StopLocation.insert_all(locations) }
    end

    def ar_one_by_one(batch)
      batch
        .map { |batch_line| batch_line.map { |line| FIELDS.zip(line).to_h } }
        .then { |locations| locations.each { |location| StopLocation.create!(location) } }
    end
  end
end
