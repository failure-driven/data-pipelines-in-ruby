# frozen_string_literal: true

require "active_record"
require "activerecord-import/base"
require "activerecord-import/active_record/adapters/postgresql_adapter"
require "pry"
require "unicode_plot"

$LOAD_PATH << File.join(
  File.expand_path(__dir__)
)
require "models/stop_location"
require "models/scan"

def db_configuration
  db_configuration_file = File.join(
    File.expand_path(__dir__), "..", "db", "config.yml"
  )
  YAML.load(File.read(db_configuration_file)) # rubocop:disable Security/YAMLLoad
end

ActiveRecord::Base.establish_connection(
  db_configuration["development"]
)

data = Scan.where(scan_on: true).order(:date_time).pluck(:date_time).map(&:hour)
UnicodePlot.histogram(data, title: "Scan On", nbins: 24).render

data = Scan.where(scan_on: false).order(:date_time).pluck(:date_time).map(&:hour)
UnicodePlot.histogram(data, title: "Scan Off", nbins: 24).render

# require "pry"
# binding.pry

# top 10 cards
# top_10_cards = Scan.group(:card_id).order(count: :desc).limit(10).count.keys
# top_card_scans = Scan.where(card_id: top_10_cards.first).order(:date_time).pluck(:date_time).map(&:hour)
# UnicodePlot.histogram(top_card_scans, title: "Top card scans: #{top_10_cards.first}", nbins: 24).render

# top_card_scans = Scan.where(card_id: top_10_cards.first)
# top_card_scans.map do |scan|
#   puts [
#     scan.date_time,
#     StopLocation.find_by(id: scan.stop_id)&.location,
#     scan.route_id,
#   ].inspect
# end
