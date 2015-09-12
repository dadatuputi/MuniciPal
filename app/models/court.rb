class Court < ActiveRecord::Base
  serialize :geometry, JSON

  has_many :citations

  def self.find_by_name(value)
    find_by name: normalize_name(value)
  end

  def name=(value)
    super self.class.normalize_name(value)
  end



  def self.normalize_name(name)
    name = name.to_s.upcase # store all court names uppercase so that we find them case-insensitively
    name = ALIASES.fetch(name, name) # homogenize names (some courts' names appear different ways)
    name
  end

  ALIASES = {
    "BERKELEY 1" => "BERKELEY",
    "BERKELEY 2" => "BERKELEY",
    "CITY OF ST. LOUIS" => "ST. LOUIS CITY",
    "TOWN & COUNTRY" => "TOWN AND COUNTRY"
  }.freeze

end
