class Court < ActiveRecord::Base
  serialize :geometry, JSON

  has_many :citations

  def self.find_by_name(value)
    where(["UPPER(name) = ?", normalize_name(value.upcase)]).first # compare names case-insensitively
  end

  def self.normalize_name(name)
    ALIASES.fetch(name, name).strip # homogenize names (some courts' names appear different ways)
  end

  def name=(value)
    super value.strip
  end

  ALIASES = {
    "ST. LOUIS CITY" => "CITY OF ST. LOUIS",
    "TOWN & COUNTRY" => "TOWN AND COUNTRY"
  }.freeze

end
