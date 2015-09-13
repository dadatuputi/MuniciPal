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

end
