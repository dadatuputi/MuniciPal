# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

require "progressbar"
require "csv"

Citation.delete_all
rows = CSV.read(Rails.root.join("db/citations.csv"), headers: true)
pbar = ProgressBar.new("citations", rows.count)
rows.each do |row|
  Citation.new(row.to_h).save!
  pbar.inc
end
pbar.finish

Violation.delete_all
rows = CSV.foreach(Rails.root.join("db/violations.csv"), headers: true)
pbar = ProgressBar.new("citations", rows.count)
rows.each do |row|
  attrs = row.to_h
  attrs["fine_amount"] = attrs["fine_amount"][1..-1].to_d if attrs["fine_amount"]
  attrs["court_cost"] = attrs["court_cost"][1..-1].to_d if attrs["court_cost"]
  Violation.create!(attrs)
  pbar.inc
end
pbar.finish
