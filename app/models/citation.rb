class Citation < ActiveRecord::Base
  attr_accessor :court_location, :court_address

  belongs_to :court
  has_many :violations, foreign_key: :citation_number, primary_key: :citation_number

  before_create :find_or_create_associated_court



private

  def find_or_create_associated_court
    self.court = Court.find_or_create_by(name: court_location.upcase, address: court_address) if court_location
  end

end
