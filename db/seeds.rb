# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

require "progressbar"
require "csv"


# Import citations.csv

Citation.delete_all
rows = CSV.read(Rails.root.join("db/citations.csv"), headers: true)
pbar = ProgressBar.new("citations", rows.count)
rows.each do |row|
  Citation.new(row.to_h).save!
  pbar.inc
end
pbar.finish


# Import violations.csv

Violation.delete_all
rows = CSV.foreach(Rails.root.join("db/violations.csv"), headers: true)
pbar = ProgressBar.new("violations", rows.count)
rows.each do |row|
  attrs = row.to_h
  attrs["fine_amount"] = attrs["fine_amount"][1..-1].to_d if attrs["fine_amount"]
  attrs["court_cost"] = attrs["court_cost"][1..-1].to_d if attrs["court_cost"]
  Violation.create!(attrs)
  pbar.inc
end
pbar.finish


# Import courts.geojson

geometry = ActiveSupport::JSON.decode(File.read(Rails.root.join("db/courts.geojson")))["features"]
unmatched_courts = []
pbar = ProgressBar.new("geometry", geometry.count)
geometry.each do |feature|
  court = Court.find_by_name feature["properties"]["court_name"]
  if court
    court.update_attribute :geometry, feature["geometry"]
  else
    unmatched_courts.push feature["properties"]["court_name"]
  end
  pbar.inc
end
pbar.finish

if unmatched_courts.any?
  unmatched_courts = unmatched_courts.uniq.sort
  puts "\e[33mSkipping geometry for #{unmatched_courts.count} courts that we don't have any citations for:"
  unmatched_courts.each do |name|
    puts "  #{name}"
  end
  print "\e[0m"
end

