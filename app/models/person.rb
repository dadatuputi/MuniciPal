class Person < ActiveRecord::Base

  has_many :citations
  has_many :violations, through: :citations

  def warrants
    violations.warrants
  end

end
