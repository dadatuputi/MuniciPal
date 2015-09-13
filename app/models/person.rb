class Person < ActiveRecord::Base

  has_many :citations
  has_many :violations, through: :citations

  def self.find_by_name(name)
    where(["(first_name || ' ' || last_name) = ?", name]).first
  end

  def warrants
    violations.warrants
  end

  def name
    [first_name, last_name].join " "
  end

  def confirm_birthday?(birthday)
    self.date_of_birth == Date.parse(birthday)
  rescue ArgumentError # an invalid date is not this person's birthday
    false
  end

end
