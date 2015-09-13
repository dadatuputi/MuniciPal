@MunicipalMap =

  render: ->
    defaultStyle =
      color: "#2262CC"
      weight: 2
      opacity: 0.6
      fillOpacity: 0.1
      fillColor: "#2262CC"

    highlightStyle =
      color: '#2262CC'
      weight: 3
      opacity: 0.6
      fillOpacity: 0.65
      fillColor: '#2262CC'

    map = L.map('map').setView([38.659003, -90.199402], 10)

    redirectToCourt = (url, context)->
      Turbolinks.visit String(@)

    highlightPolygon = (e) ->
      layer = e.target
      layer.setStyle(highlightStyle) if layer
      # layer.closePopup() if layer

    removeHighlight = (e) ->
      layer = e.target
      layer.setStyle(defaultStyle) if layer
      # layer.openPopup() if layer

    $.get('/geodata/muny').done (data) ->
      muny_geojson = data
      municipalities = new L.LayerGroup()
      onEachFeature = (feature, layer) ->
        layer.setStyle(defaultStyle)
        layer.on("click", redirectToCourt, feature.properties.url, @)
        layer.on("mouseover", highlightPolygon)
        layer.on("mouseout", removeHighlight)


      L.geoJson(muny_geojson, onEachFeature: onEachFeature).addTo map
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
