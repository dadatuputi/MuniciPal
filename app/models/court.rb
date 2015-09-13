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

  def online_payment_website
    # WEBSITES.fetch online_payment_provider
    "https://www.ipaycourt.com/frmCitationSearch.aspx?ori="
  end

  ALIASES = {
    "ST. LOUIS CITY" => "CITY OF ST. LOUIS",
    "TOWN & COUNTRY" => "TOWN AND COUNTRY"
  }.freeze

  WEBSITES = {
    "iPayCourt" => "https://www.ipaycourt.com/frmCitationSearch.aspx",
    "nCourt" => "https://www.ncourt.com/MakePayment.aspx",
    "IPG" => "https://www.trafficpayment.com/InvoiceInfo.aspx?csdId=324&AspxAutoDetectCookieSupport=1"
  }.freeze

end
