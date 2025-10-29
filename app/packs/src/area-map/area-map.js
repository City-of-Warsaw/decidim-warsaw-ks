$(document).ready(function () {
  const osmUrlA = Decidim.config.get('osmUrl') + "/tile/{z}/{x}/{y}.png";
  const nominatimUrlA = Decidim.config.get('nominatimUrl');
  const mapA = L.map("area-map", {
    minZoom: 10,
    maxZoom: 18,
    gestureHandling: true,
  }).setView([52.22977, 21.01178], 11);

  const osm = L.tileLayer(osmUrlA, {
    attribution:
      '&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors',
  });

  osm.addTo(mapA);

  var featureGroupA = new L.FeatureGroup();
  mapA.addLayer(featureGroupA);

  var BOLeafIcon = L.Icon.extend({
    options: {
      iconUrl: Decidim.config.get('markerIconUrl'),
      iconRetinaUrl: Decidim.config.get('markerIconRetinaUrl'),
      shadowUrl: Decidim.config.get('markerShadowUrl'),
      iconSize: [25, 41],
      iconAnchor: [12, 41],
      popupAnchor: [1, -34],
      tooltipAnchor: [16, -28],
      shadowSize: [41, 41]
    },
    _getIconUrl: function (name) {
      return L.Icon.prototype._getIconUrl.call(this, name);
    }
  });
  var mapIcon = new BOLeafIcon();

  var drawControl = new L.Control.Draw({
    draw: {
      rectangle: false,
      circle: false,
      polyline: false,
      circlemarker: false,
      marker: {
        icon: mapIcon,
      },
    },
    edit: {
      featureGroup: featureGroupA,
    },
  });

  mapA.addControl(drawControl);

  function isJSON(str) {
    try {
      return JSON.parse(str) && !!str;
    } catch (e) {
      return false;
    }
  }

  if (isJSON($("#coordinates").val())) {
    const data = JSON.parse($("#coordinates").val());
    const layer = L.geoJson(data, {
      onEachFeature: function (feature, layer) {
        featureGroupA.addLayer(layer);

        layer.on('click', function (e) {
          if ($(".leaflet-draw-edit-remove").hasClass("leaflet-draw-toolbar-button-enabled")) {
            featureGroupA.removeLayer(layer);
          }
        });
      }
    });

    if (featureGroupA.getBounds().isValid()) {
      setTimeout(() => mapA.fitBounds(featureGroupA.getBounds(), {"animate": false}), 100);
    }
  }

  function serializeLocations() {
    $("#coordinates").val(JSON.stringify(featureGroupA.toGeoJSON()));
  }

  mapA.on(L.Draw.Event.CREATED, function (e) {
    var layer = e.layer;

    featureGroupA.addLayer(layer);
    serializeLocations();
  });

  mapA.on(L.Draw.Event.EDITED, serializeLocations);
  mapA.on(L.Draw.Event.DELETED, serializeLocations);


  // tworzenie i edycja konsultacji
  $('#clear_map').click(function() {
    featureGroupA.clearLayers();
    serializeLocations();
  });

new Autocomplete("area-search", {
  // default selects the first item in
  // the list of results
  selectFirst: true,

  // The number of characters entered should start searching
  howManyCharacters: 5,

  // onSearch
  onSearch: ({ currentValue }) => {
    // You can also use static files
    // const api = '../static/search.json'
    const api = `${nominatimUrlA}/search?format=geojson&limit=5&addressdetails=1&countrycodes=pl&city=Warszawa&street=${encodeURI(
        currentValue
    )}`;

    return new Promise((resolve) => {
      fetch(api)
          .then((response) => response.json())
          .then((data) => {
            resolve(data.features);
          })
          .catch((error) => {
            console.error(error);
          });
    });
  },
  // nominatim GeoJSON format parse this part turns json into the list of
  // records that appears when you type.
  onResults: ({ currentValue, matches, template }) => {
    const regex = new RegExp(currentValue, "gi");

    // if the result returns 0 we
    // show the no results element
    return matches === 0
        ? template
        : matches
            .map((element) => {
              // const display_name = prepareDisplayName(element.properties);
              return `
          <li class="loupe">
            <p>
              ${element.properties.display_name.replace(
                  regex,
                  (str) => `<b>${str}</b>`
              )}
            </p>
          </li> `;
            })
            .join("");
  },

  // we add an action to enter or click
  onSubmit: ({ object, element }) => {
    const { display_name, address } = object.properties;
    const cord = object.geometry.coordinates;

    // sets the view of the map
    mapA.setView([cord[1], cord[0]], 14);
  },

  // get index and data from li element after
  // hovering over li with the mouse or using
  // arrow keys ↓ | ↑
  onSelectedItem: ({ index, element, object }) => {
    // console.log("onSelectedItem:", index, element, object);
  },

  // the method presents no results element
  noResults: ({ currentValue, template }) =>
      template(`<li>Brak wyników dla: "${currentValue}"</li>`),
});

}); // END $(document).ready(function () {
