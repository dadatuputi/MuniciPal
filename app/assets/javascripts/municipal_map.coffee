$(document).ready ->
  map = L.map('map').setView([38.627003, -90.199402], 13)

  $.get('/geodata/muny').done (data) ->
    muny_geojson = data
    municipalities = new L.LayerGroup();
    L.geoJson(muny_geojson).addTo(map);
    return

  # More here: http://leaflet-extras.github.io/leaflet-providers/preview/
  tileSources =
    mapkik:
      url: "http://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png"
      attribution: '&copy; <a href="http://www.openstreetmap.org/copyright">OpenStreetMap</a>'
    bw:
      url: "http://{s}.tiles.wmflabs.org/bw-mapnik/{z}/{x}/{y}.png"
      attribution: '&copy; <a href="http://www.openstreetmap.org/copyright">OpenStreetMap</a>'
    hot: 
      url: 'http://{s}.tile.openstreetmap.fr/hot/{z}/{x}/{y}.png'
      attribution: '&copy; <a href="http://www.openstreetmap.org/copyright">OpenStreetMap</a>'
    transport:
      url: 'http://{s}.tile.thunderforest.com/transport/{z}/{x}/{y}.png'
      attribution: '&copy; <a href="http://www.openstreetmap.org/copyright">OpenStreetMap</a>'
    roads:
      url: 'http://openmapsurfer.uni-hd.de/tiles/roads/x={x}&y={y}&z={z}'
      attribution: '&copy; <a href="http://www.openstreetmap.org/copyright">OpenStreetMap</a>'
    full:
      url: 'http://{s}.tile.openstreetmap.se/hydda/full/{z}/{x}/{y}.png'
      attribution: '&copy; <a href="http://www.openstreetmap.org/copyright">OpenStreetMap</a>'

  tileSource = tileSources.transport

  tileLayer = L.tileLayer(tileSource.url, {
    maxZoom: 19,
    attribution: tileSource.attribution
  })

  tileLayer.addTo(map)
