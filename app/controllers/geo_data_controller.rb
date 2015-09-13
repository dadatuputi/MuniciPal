class GeoDataController < ApplicationController
  def municipalities
    munies = Court.where.not(geometry: nil).pluck(:id, :name, :geometry).map { |id, name, geometry|
      { "type" => "Feature",
        "properties" => {"url" => court_path(id: id), "popupContent" => name},
        "geometry" => geometry } }

    json = Court.benchmark("render json") { Oj.dump(munies) }
    render json: json
  end
end
