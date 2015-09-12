class SMS
  include ActiveModel::Validations

  attr_accessor :to, :from, :text
  validates :to, :from, :text, presence: true, allow_blank: false
  validates :to, :from, length: { is: 11 }, numericality: { only_integer: true }

  def initialize(params)
      @to = params["To"]
      @from = params["From"]
      @text = params["Text"]
  end
end
