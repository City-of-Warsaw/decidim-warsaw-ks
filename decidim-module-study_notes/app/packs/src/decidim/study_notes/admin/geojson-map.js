var osmUrl = Decidim.config.get('osmUrl') + "/tile/{z}/{x}/{y}.png";
    
var map = L.map("map", {
  zoomControl: false
}).setView([52.22977, 21.01178], 11);

L.tileLayer(osmUrl, {
  attribution:
    '&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors',
}).addTo(map);
 
const layer = L.geoJSON(JSON.parse(window.document.querySelector("input[name=locations]").value));
layer.addTo(map);

map.fitBounds(layer.getBounds(), {"animate": false});