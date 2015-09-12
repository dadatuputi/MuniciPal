class GeoDataController < ApplicationController
  def municipalities
    munies = Court.where.not(geometry: nil).pluck(:geometry)
    render json: munies
  end
end
