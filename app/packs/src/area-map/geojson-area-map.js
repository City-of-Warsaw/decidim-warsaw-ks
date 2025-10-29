import "src/geojson-map/leaflet.draw.modCS.js";

$(document).ready(function () {
  const osmUrl = Decidim.config.get("osmUrl") + "/tile/{z}/{x}/{y}.png";
  const nominatimUrl = Decidim.config.get("nominatimUrl");

  const map = L.map("area-map-custom", {
    minZoom: 10,
    maxZoom: 18,
    gestureHandling: true,
  }).setView([52.22977, 21.01178], 11);

  const osm = L.tileLayer(osmUrl, {
    attribution:
      '&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors',
  });

  osm.addTo(map);

  var featureGroup = new L.FeatureGroup();
  map.addLayer(featureGroup);

  var drawControlDraw = new L.Control.Draw({
    draw: {
      rectangle: false,
      circle: false,
      polyline: false,
      circlemarker: false,
      marker: false,
    },
    edit: {
      featureGroup,
    },
  });

  var drawControlEditOnly = new L.Control.Draw({
    draw: false,
    edit: {
      featureGroup,
    },
  });

  const coordinatesInputValue = document.querySelector("#coordinates").value;

  if (coordinatesInputValue.length > 2) {
    drawControlEditOnly.addTo(map);

    let geojson;

    if (coordinatesInputValue.includes("FeatureCollection")) {
      geojson = JSON.parse(coordinatesInputValue);
    } else {
      const coordinates = JSON.parse(coordinatesInputValue);
      const polygon = L.polygon(coordinates);

      geojson = {
        type: "Feature",
        geometry: {
          type: "Polygon",
          coordinates: [
            coordinates.map(function (x) {
              return [x[1], x[0]];
            }),
          ],
        },
        properties: {},
      };
    }

    const layer = L.geoJson(geojson, {
      onEachFeature: function (feature, layer) {
        featureGroup.addLayer(layer);

        layer.on("click", function (e) {
          if (
            $(".leaflet-draw-edit-remove").hasClass(
              "leaflet-draw-toolbar-button-enabled"
            )
          ) {
            featureGroup.removeLayer(layer);
          }
        });
      },
    });

    if (featureGroup.getBounds().isValid()) {
      setTimeout(
        () => map.fitBounds(featureGroup.getBounds(), { animate: false }),
        100
      );
    }
  } else {
    drawControlDraw.addTo(map);
  }

  map.on(L.Draw.Event.CREATED, function (e) {
    var layer = e.layer;

    featureGroup.addLayer(layer);
    serializeLocations();

    drawControlDraw.remove(map);
    drawControlEditOnly.addTo(map);
  });

  map.on(L.Draw.Event.EDITED, serializeLocations);
  map.on(L.Draw.Event.DELETED, function () {
    serializeLocations();

    if (featureGroup.getLayers().length === 0) {
      drawControlEditOnly.remove(map);
      drawControlDraw.addTo(map);
    }
  });

  function serializeLocations() {
    const geojson = featureGroup.toGeoJSON();
    const coordinates = geojson.features
      .map((feature) => {
        if (feature.geometry.type === "Polygon") {
          return feature.geometry.coordinates[0].map((coord) => [
            coord[1],
            coord[0],
          ]);
        }

        return [];
      })
      .filter((coords) => coords.length > 0);

    $("#coordinates").val(JSON.stringify(coordinates.flat()));
  }

  function onChange(event) {
    var reader = new FileReader();
    reader.onload = onReaderLoad;
    reader.readAsText(event.target.files[0]);
    map.setZoom(16, { animate: false });
    $("#file_name").text(event.target.files[0].name);
  }

  function onReaderLoad(event) {
    var data = JSON.parse(event.target.result);

    featureGroup.clearLayers();

    if (
      data.features.filter(({ geometry }) => geometry.type === "Polygon")
        .length > 1
    ) {
      alert(
        "Plik zawiera więcej niż jeden polygon. Do wyznaczenia obszaru zostanie użyty pierwszy z nich."
      );
    } else if (
      data.features.filter(({ geometry }) => geometry.type === "Polygon")
        .length === 0
    ) {
      alert(
        "Plik nie zawiera polygonów. Obszar nie został wyznaczony. Wybierz inny plik."
      );
      $("#file_name").text("");
      return;
    }

    const coordinates = data.features.find(
      ({ geometry }) => geometry.type === "Polygon"
    ).geometry.coordinates[0];

    const geojson = {
      type: "Feature",
      geometry: {
        type: "Polygon",
        coordinates: [
          coordinates.map(function (x) {
            return [x[1], x[0]];
          }),
        ],
      },
      properties: {},
    };

    const layer = L.geoJson(geojson, {
      onEachFeature: function (feature, layer) {
        featureGroup.addLayer(layer);

        layer.on("click", function (e) {
          if (
            $(".leaflet-draw-edit-remove").hasClass(
              "leaflet-draw-toolbar-button-enabled"
            )
          ) {
            featureGroup.removeLayer(layer);
          }
        });
      },
    });

    map.fitBounds(coordinates, { animate: false });
    serializeLocations();

    drawControlDraw.remove(map);
    drawControlEditOnly.addTo(map);
  }

  $("#geojson_preview_file").change(onChange);

  $("#add_geojson_area").click(function () {
    $("#geojson_preview_file").click();
  });

  $("#clear_map").click(function () {
    featureGroup.clearLayers();
    serializeLocations();
    $("#file_name").text("");
    $("#geojson_preview_file").val("");

    drawControlEditOnly.remove(map);
    drawControlDraw.addTo(map);
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
      const api = `${nominatimUrl}/search?format=geojson&limit=5&addressdetails=1&countrycodes=pl&city=Warszawa&street=${encodeURI(
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
      map.setView([cord[1], cord[0]], 14);
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
});
