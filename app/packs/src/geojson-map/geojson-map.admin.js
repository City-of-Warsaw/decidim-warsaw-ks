/**
 * Map Location
 */

var osmUrl = Decidim.config.get('osmUrl') + "/tile/{z}/{x}/{y}.png";
const nominatimUrl = Decidim.config.get('nominatimUrl');

// set map
var map = L.map("map", {
  minZoom: 10,
  maxZoom: 18,
  gestureHandling: true,
}).setView([52.22977, 21.01178], 11);

const TOOLTIP_ZOOM_THRESHOLD = 15;

$("#map").removeAttr("tabIndex");

L.tileLayer(osmUrl, {
  attribution:
    '&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors',
}).addTo(map);

L.Marker.prototype.options.icon = L.icon({
    iconUrl:       Decidim.config.get('markerIconUrl'),
    iconRetinaUrl: Decidim.config.get('markerIconRetinaUrl'),
    shadowUrl:     Decidim.config.get('markerShadowUrl'),
    iconSize:    [25, 41],
    iconAnchor:  [12, 41],
    popupAnchor: [1, -34],
    tooltipAnchor: [16, -28],
    shadowSize:  [41, 41]
});

const layer = L.geoJSON(JSON.parse($("input[name=locations]").val()));
layer.addTo(map);

map.fitBounds(layer.getBounds(), {"animate": false});