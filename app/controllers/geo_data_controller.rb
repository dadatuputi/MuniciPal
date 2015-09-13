class GeoDataController < ApplicationController
  def municipalities
    munies = Court.where.not(geometry: nil).map do |court|
                { type: "Feature",
                  properties: {url: court_path(court), popupContent: court.name},
                  geometry: court.geometry
                }
            end
    render json: munies
  end
end
