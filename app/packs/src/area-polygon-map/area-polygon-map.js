var MarkerIcon = L.Icon.extend({
  options: {
    iconUrl: Decidim.config.get("markerIconUrl"),
    iconRetinaUrl: Decidim.config.get("markerIconRetinaUrl"),
    shadowUrl: Decidim.config.get("markerShadowUrl"),
    iconSize: [25, 41],
    iconAnchor: [12, 41],
    popupAnchor: [1, -34],
    tooltipAnchor: [16, -28],
    shadowSize: [41, 41],
  },
  _getIconUrl: function (name) {
    return L.Icon.prototype._getIconUrl.call(this, name);
  },
});

var mapIcon = new MarkerIcon();

const mapsData = {
  area_map_mobile: {
    center: [52.22977, 21.01178],
    zoom: 11,
  },
  area_map_desktop: {
    center: [52.22977, 21.01178],
    zoom: 11,
  },
};

function initMap(element) {
  const L_tiles = Decidim.config.get("osmUrl") + "/tile/{z}/{x}/{y}.png";
  const L_options = {
    attribution:
      '&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors',
    minZoom: 10,
    maxZoom: 18,
  };
  const id = element.dataset.map;
  const data = mapsData[id];
  const map = L.map(element, { gestureHandling: true }).setView(
    data.center,
    data.zoom
  );

  L.tileLayer(L_tiles, L_options).addTo(map);

  var coordinates = $("#coordinatesA").val();
  var areaPolygon;

  if ($("#coordinatesA").val().includes("FeatureCollection")) {
    areaPolygon = L.geoJSON(JSON.parse(coordinates)).addTo(map);
  } else {
    areaPolygon = L.polygon(JSON.parse(coordinates)).addTo(map);
  }

  map.fitBounds(areaPolygon.getBounds(), { animate: false });
}

$(document).ready(function () {
  const areaMaps = document.querySelectorAll("[data-map]:not([hidden])");
  areaMaps.forEach(initMap);
});
