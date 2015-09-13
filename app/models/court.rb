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

  def online_payment_provider=(value)
    value = value.to_s[/^[^(]*/].strip # remove parenthetical comments
    value = nil if ["", "N/A"].member? value
    value = "nCourt" if value == "Ncourt"
    value = "iPayCourt" if value == "nCourt & iPayCourt"
    super value
  end

  def phone_number=(value)
    value = value.to_s[/^[^(]*/].strip # remove parenthetical comments
    value = nil if value == "not listed"
    super value
  end

  def supports_online_payments?
    online_payment_provider.present?
  end

  def supports_community_service_for?(citation)
    # It is probably not true that every courthouse
    # will support community service for every citation!
    true
  end

  def online_payment_website
    # WEBSITES.fetch online_payment_provider
    "https://www.ipaycourt.com/frmCitationSearch.aspx?ori="
  end

  def add_geometry!(new_geometry)
    unless self.geometry.blank?
      multi_geometry = { "type" => "MultiPolygon", "coordinates" => [] }
      with_each_polygon_in(self.geometry) { |polygon| multi_geometry["coordinates"].push polygon }
      with_each_polygon_in(new_geometry)  { |polygon| multi_geometry["coordinates"].push polygon }
      new_geometry = multi_geometry
    end

    update_attribute :geometry, new_geometry
  end

  def with_each_polygon_in(geometry, &block)
    case geometry["type"]
    when "Polygon" then block.call(geometry["coordinates"])
    when "MultiPolygon" then geometry["coordinates"].each(&block)
    else raise NotImplementedError, "I don't recognize the geometry type '#{geometry["type"]}'"
    end
  end

  ALIASES = {
    "ST. LOUIS CITY" => "CITY OF ST. LOUIS",
    "TOWN & COUNTRY" => "TOWN AND COUNTRY",
    "UNINCORPORATED ST. LOUIS COUNTY" => "UNINCORPORATED",

    # !NOTE: These actually have different courthouses (and citations
    # are particular to them), so it is not right to merge these all
    # into one "Unincorporated" Courthouse! But we don't have a way of
    # separating the geometry out into the four quadrants; so we're going
    # to converge them so that we can show all the geometry for the demo.
    "UNINCORPORATED CENTRAL ST. LOUIS COUNTY" => "UNINCORPORATED",
    "UNINCORPORATED NORTH ST. LOUIS COUNTY" => "UNINCORPORATED",
    "UNINCORPORATED SOUTH ST. LOUIS COUNTY" => "UNINCORPORATED",
    "UNINCORPORATED WEST ST. LOUIS COUNTY" => "UNINCORPORATED"
  }.freeze

  WEBSITES = {
    "iPayCourt" => "https://www.ipaycourt.com/frmCitationSearch.aspx",
    "nCourt" => "https://www.ncourt.com/MakePayment.aspx",
    "IPG" => "https://www.trafficpayment.com/InvoiceInfo.aspx?csdId=324&AspxAutoDetectCookieSupport=1"
  }.freeze

end
