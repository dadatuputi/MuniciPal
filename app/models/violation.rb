class Violation < ActiveRecord::Base

  belongs_to :citation, foreign_key: :citation_number, primary_key: :citation_number

end
