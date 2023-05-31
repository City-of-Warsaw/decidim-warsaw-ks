const osmUrl = "https://osm.cdsh.dev/hot/{z}/{x}/{y}.png";
const nominatimUrl = "https://nominatim.cdsh.dev";

const map = L.map("map", {
  minZoom: 10,
  maxZoom: 15,
  gestureHandling: true,
}).setView([52.22977, 21.01178], 11);

const osm = L.tileLayer(osmUrl, {
  attribution:
    '&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors',
});

osm.addTo(map);

// const coords = JSON.parse(document.querySelector("#coordinates").value);
// const array_coords = $.parseJSON(coords);

let locations = [];
// const inputsWrapper = document.querySelector(".inputs-wrapper");

const addInputs = () => {
  // inputsWrapper.innerHTML = "";
  const coordinates = [];

  locations[0].map((location) => {
    coordinates.push([location.lat, location.lng]);
  });

  // const input = document.createElement("input");
  const input = document.getElementById("coordinates");
  // input.setAttribute("id", "coordinates");
  // input.setAttribute("type", "hidden");
  // input.setAttribute("disabled", "true");
  input.setAttribute("value", JSON.stringify(coordinates));
  // inputsWrapper.appendChild(input);

  // console.log(input.value);
};

let firstRender = true;

const areaSelection = new window.leafletAreaSelection.DrawAreaSelection({
  active: true,
  onPolygonReady: (polygon) => {
    locations = polygon._latlngs;
    addInputs();
    if (firstRender) map.fitBounds(polygon.getBounds());
    firstRender = false;
  },
});

map.addControl(areaSelection);

let cords = document.querySelector("#coordinates").value; // ""
let coordinates = [];

if (cords) {
  coordinates = JSON.parse(cords).map(function (x) {
    return { lat: x[0], lng: x[1] }
  });
}

const drawPolygon = () => {
  let brect = map.getContainer().getBoundingClientRect();

  coordinates.map((coordinate) => {
    const point = map.latLngToContainerPoint(coordinate);
    map.fire(
        "as:point-add",
        new MouseEvent("click", {
          clientX: point.x + brect.left,
          clientY: point.y + +brect.top,
        })
    );
  });
  map.fire("as:creation-end");
};

if (cords) {
  drawPolygon();
}

new Autocomplete("search", {
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