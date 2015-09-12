class Violation < ActiveRecord::Base

  belongs_to :citation, foreign_key: :citation_number, primary_key: :citation_number

  def self.warrants
    where(warrant_status: true)
  end

  def warrant?
    warrant_status?
  end

end
