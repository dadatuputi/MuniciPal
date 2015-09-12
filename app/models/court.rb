class Court < ActiveRecord::Base

  has_many :citations

  def name=(value)
    super value && value.upcase
  end

end
