class Person < ActiveRecord::Base

  has_many :citations
  has_many :violations, through: :citations

  def warrants
    violations.warrants
  end

  def name
    [first_name, last_name].join " "
  end

end
