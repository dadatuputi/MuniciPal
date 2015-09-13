# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

require "progressbar"
require "csv"

skip = ENV["SKIP"].to_s.split(",")

def announce(message)
  puts "\n\e[34;1m#{message}...\e[0m"
end



# Import MunicipalCourtLocations.csv, courts.geojson

unless skip.member?("courts")
  Court.delete_all



  announce "Importing MunicipalCourtLocations.csv..."
  rows = CSV.read(Rails.root.join("db/MunicipalCourtLocations.csv"), headers: true)
  pbar = ProgressBar.new("progress", rows.count)
  rows.each do |row|
    Court.create!(
      name: row["Municipali"],
      address: row["Address"],
      zip_code: row["Zip_Code"],
      lat: row[0], # something weird with the name of the column
      long: row["Y"])
    pbar.inc
  end
  pbar.finish



  announce "Importing MunicipalCourtWebsites.csv..."
  rows = CSV.read(Rails.root.join("db/MunicipalCourtWebsites.csv"), headers: true)
  unmatched_courts = []
  pbar = ProgressBar.new("progress", rows.count)
  rows.each do |row|
    next if row["Municipality"].nil?

    court = Court.find_by_name row["Municipality"]
    if court
      court.update_attributes!(
        municipal_website: row["Municipal Website"],
        website: row["Municipal Court Website"],
        phone_number: row["Court Clerk Phone Number Listed on Muni Site?"],
        online_payment_provider: row["Online Payment System Provider"])
    else
      unmatched_courts.push row["Municipality"]
    end
    pbar.inc
  end
  pbar.finish

  if unmatched_courts.any?
    unmatched_courts = unmatched_courts.uniq.sort
    puts "\n\e[34mDidn't find website data for #{unmatched_courts.count} courts in `Municipal Court Websites.csv`:"
    unmatched_courts.each do |name|
      puts "  #{name}"
    end
    print "\e[0m"
  end



  announce "Importing courts.geojson..."
  geometry = ActiveSupport::JSON.decode(File.read(Rails.root.join("db/courts.geojson")))["features"]
  unmatched_courts = []
  pbar = ProgressBar.new("progress", geometry.count)
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
    puts "\n\e[34mSkipping geometry for #{unmatched_courts.count} courts that we don't have any citations for:"
    unmatched_courts.each do |name|
      puts "  #{name}"
    end
    print "\e[0m"
  end

  unplotted_courts = Court.where(geometry: nil).pluck(:name).uniq.sort
  if unplotted_courts.any?
    puts "\n\e[33mThere are still #{unplotted_courts.count} courts that we don't have any geometry for:"
    unplotted_courts.each do |name|
      puts "  #{name}"
    end
    print "\e[0m"
  end
end



# Import citations.csv

unless skip.member?("citations")
  announce "Importing citations.csv..."
  missing_citation_courts = []
  Citation.delete_all
  rows = CSV.read(Rails.root.join("db/citations.csv"), headers: true)
  pbar = ProgressBar.new("progress", rows.count)
  rows.each do |row|
    citation = Citation.new(row.to_h).tap(&:save!)
    missing_citation_courts.push citation.court_location if citation.court_location && !citation.court
    pbar.inc
  end
  pbar.finish

  if missing_citation_courts.any?
    missing_citation_courts = missing_citation_courts.uniq.sort
    puts "\n\e[33mWe have citations for #{missing_citation_courts.count} courts that aren't in MunicipalCourtLocations.csv:"
    missing_citation_courts.each do |name|
      puts "  #{name}"
    end
    print "\e[0m"
  end
end



# Import violations.csv

unless skip.member?("violations")
  announce "Importing violations.csv..."
  Violation.delete_all
  rows = CSV.foreach(Rails.root.join("db/violations.csv"), headers: true)
  pbar = ProgressBar.new("progress", rows.count)
  rows.each do |row|
    attrs = row.to_h
    attrs["fine_amount"] = attrs["fine_amount"][1..-1].to_d if attrs["fine_amount"]
    attrs["court_cost"] = attrs["court_cost"][1..-1].to_d if attrs["court_cost"]
    Violation.create!(attrs)
    pbar.inc
  end
  pbar.finish
end
