class CourtController < ApplicationController
  skip_before_action :verify_authenticity_token

  def feedback
    puts params

    head :ok
  end

end
