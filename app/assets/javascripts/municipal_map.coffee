$(document).ready ->
  $.get('/geodata/muny').done (data) ->
    muny_geojson = data
    municipalities = new L.LayerGroup();
    L.geoJson(muny_geojson).addTo(map);
    return

  OpenStreetMap_Mapnik = L.tileLayer('http://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
  	maxZoom: 19,
  	attribution: '&copy; <a href="http://www.openstreetmap.org/copyright">OpenStreetMap</a>'
  })


  map = L.map('map').setView([38.627003, -90.199402], 13)



  OpenStreetMap_Mapnik.addTo(map)
