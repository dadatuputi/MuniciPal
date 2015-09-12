class Citation < ActiveRecord::Base

  # Fields that we'll extract to the association court
  attr_accessor :court_location,
                :court_address

  # Fields that we'll extract to the associated person
  attr_accessor :first_name,
                :last_name,
                :date_of_birth,
                :defendant_address,
                :defendant_city,
                :defendant_state,
                :drivers_license_number

  belongs_to :court
  belongs_to :person
  has_many :violations, foreign_key: :citation_number, primary_key: :citation_number

  before_create :find_or_create_associated_court
  before_create :find_or_create_associated_person



private

  def find_or_create_associated_court
    self.court = Court.find_by_name(court_location) if court_location
  end

  def find_or_create_associated_person
    self.person = Person.find_or_create_by(first_name: first_name, last_name: last_name)
    self.person.date_of_birth = date_of_birth unless date_of_birth.blank?
    self.person.address = defendant_address unless defendant_address.blank?
    self.person.city = defendant_city unless defendant_city.blank?
    self.person.state = defendant_state unless defendant_state.blank?
    self.person.drivers_license_number = drivers_license_number unless drivers_license_number.blank?
    self.person.save!
  end

end
