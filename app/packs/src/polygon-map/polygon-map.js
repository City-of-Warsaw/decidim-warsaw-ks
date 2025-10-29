/**
 * Map Location
 */

import "./leaflet.snogylop.js";
import "../locations-map/leaflet-active-area.js";

const osmUrl = Decidim.config.get("osmUrl") + "/tile/{z}/{x}/{y}.png";
const nominatimUrl = Decidim.config.get("nominatimUrl");

const loadingAddressText = "Wczytywanie adresu...";

const locations = {};
const markers = {};
const markersLimit = 1;
const markersRefs = [];

// polygon checking initialize elements

let INF = 10000;

class Point {
  constructor(x, y) {
    this.x = x;
    this.y = y;
  }
}

// set map
const map = L.map("map", {
  minZoom: 10,
  maxZoom: 18,
  gestureHandling: true,
}).setView([52.22977, 21.01178], 11);

$("#map").removeAttr("tabIndex");

const osm = L.tileLayer(osmUrl, {
  attribution:
    '&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors',
}).addTo(map);

map.attributionControl.setPosition("bottomleft");

if ([...rasters, ...vectors].length > 0) {
  const layerControl = L.control
    .layers({ osm }, { ...rasters, ...vectors })
    .addTo(map);
}

// icons
var mapMarker = L.Icon.extend({
  options: {
    iconUrl: Decidim.config.get("remarkMapMarkerIconUrl"),
    iconRetinaUrl: Decidim.config.get("remarkMapMarkerIconUrl"),
    iconSize: [40, 56],
    iconAnchor: [20, 56],
    popupAnchor: [20, -34],
    tooltipAnchor: [20, -28],
    shadowSize: [0, 0],
  },
  _getIconUrl: function (name) {
    return L.Icon.prototype._getIconUrl.call(this, name);
  },
});
var mapIcon = new mapMarker();

const coordinates = JSON.parse(document.querySelector("#coordinates").value);
const polygon_coords = coordinates.map(function (x) {
  return new Point(x[0], x[1]);
});

if (coordinates.length > 0) {
  const polygon = L.polygon(coordinates);
  map.fitBounds(polygon.getBounds());

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

  var geojson_ = L.geoJson(geojson, {
    invert: true,
    renderer: L.svg({ padding: 1 }),
    fillColor: "#D0D5E2",
    fillOpacity: 0.75,
    color: "#969696",
    weight: 1,
  }).addTo(map);
}

if ($("#map").hasClass("map-widget")) {
  // for widget we do redirect on click
  map.on("click", function () {
    let href = $("#map").data("href");
    window.location.href = href;
  });
} else if ($("#map").hasClass("block-commenting")) {
  // for just browsing map - do not do anything specific
  // class is added when component has blocked comments and current user is not an ad user
} else {
  map.on("click", addMarker);
}

$(".add-marker-js").on("click", function () {
  $("#map_remarks").attr("data-map-state", "marker-positioning");
});

$(".cancel-marker-js").on("click", function () {
  $("#map_remarks").removeAttr("data-map-state");
});

// markers
const markersInput = $('input[name="markersMap"]');

function addMarkers() {
  const markersJson = markersInput.val();

  for (var i = 0; i < markersRefs.length; i++) {
    map.removeLayer(markersRefs[i]);
  }

  if (markersJson.length > 0) {
    var bounds = [];
    var markersParsed = JSON.parse(markersJson);

    $.each(markersParsed, function (k, v) {
      const { lat, lng } = v;

      addMarker(
        {
          ...v,
          latlng: {
            lat,
            lng,
          },
        },
        k
      );
      bounds.push([lat, lng]);
    });
  }
}

addMarkers();

markersInput.change(addMarkers);

const inputNewLocation = $("#location-input-new");
const inputAddLocation = $("#location-input-add");

inputNewLocation.on("keypress", function (e) {
  const keycode = e.keyCode ? e.keyCode : e.which;
  if (keycode == "13") addNewLocation();
});

// add marker
function addMarker(e, id = Date.now()) {
  if (e.type === "click" && $("#new_remark form.new_remark").length > 0) return;
  if (
    e.type === "click" &&
    $("#map_remarks").attr("data-map-state") !== "marker-positioning"
  )
    return;

  $("#map_remarks").removeAttr("data-map-state");

  locations[id] = {
    lat: e.latlng.lat,
    lng: e.latlng.lng,
    display_name: e.display_name || null,
    address: e.address || null,
    id: e.id || 0,
  };

  const addressText = e.display_name || loadingAddressText;

  markers[id] = new L.marker(e.latlng, {
    draggable: e.type === "click",
    id: e.id,
    icon: new L.divIcon({
      html: `
        <div class="remark-map-marker">
          <svg width="40px" height="56px" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 46.92 64.68">
            <g>
              <path id="Subtraction_18" data-name="Subtraction 18" d="M23.46,0C10.52,0,.02,10.48,0,23.42c0,16.03,20.99,39.56,21.89,40.55.78.87,2.12.94,2.99.15.05-.05.11-.1.15-.15.89-.99,21.89-24.52,21.89-40.55C46.89,10.48,36.4,0,23.46,0Z" style="fill: ${
                e.category_color || "#197893"
              }; fill-rule: evenodd;"/>
            </g> 
            
            ${
              !e.category_icon
                ? `<circle id="Ellipse_249" data-name="Ellipse 249" cx="22.91" cy="22.62" r="13.88" style="fill: #fff;"/>`
                : ""
            }
          </svg>

          ${
            e.category_icon && e.category_icon.length > 0
              ? e.category_icon
                  .replace(/&amp;/g, "&")
                  .replace(/&lt;/g, "<")
                  .replace(/&gt;/g, ">")
                  .replace(/&quot;/g, '"')
                  .replace(/&#39;/g, "'")
              : ""
          }
        </div>
      `,
      className: "",
      iconSize: [40, 56],
      iconAnchor: [20, 56],
      popupAnchor: [20, -34],
      tooltipAnchor: [20, -28],
      shadowSize: [0, 0],
    }),
  }).addTo(map);
  // .bindPopup(addressText);

  markersRefs.push(markers[id]);

  geocodeLatLng(id, e.address == null);
  markerEvents(id);

  const added_point = new Point(
    markers[id].getLatLng()["lat"],
    markers[id].getLatLng()["lng"]
  );

  let isInPolygonArea = true;

  if (coordinates.length > 0) {
    isInPolygonArea = isInside(polygon_coords, coordinates.length, added_point);
  }

  if (e.type === "click") {
    handle_new_marker_in_polygon(isInPolygonArea, added_point, id);
  }
}

function handle_new_marker_in_polygon(isInPolygonArea, added_point, id) {
  if (!isInPolygonArea) {
    window.Decidim.currentDialogs.outOfBoundsModal.open();
    removeLocation(id);
    $("#new_remark").html("");
  } else {
    let href = $("#new_remark").data("new-remark-href");
    $.post(
      href,
      {
        _method: "get",
        remote: true,
        coords: added_point,
      },
      function (data) {
        $.globalEval(data, {
          nonce: $("meta[name=csp-nonce]").attr("content"),
        });

        fileField = $("#remark_image");
        uploadButton = $(".remark-file-button-js");
        deleteButton = $(".remark-file-delete-js");
        fileBox = $(".remark-file-box");
        fileName = $(".remark-filename-js");

        uploadButton.click(function () {
          fileField.click();
        });

        fileField.change(function () {
          if (fileField.val()) {
            fileName.html(
              fileField.val().match(/[\/\\]([\w\d\s\.\-\(\)]+)$/)[1]
            );

            fileBox.addClass("visible");
            uploadButton.hide();
          }
        });

        deleteButton.click(function () {
          fileField.val("");
          fileBox.removeClass("visible");
          uploadButton.show();
        });

        $("#new_remark .close-button").click(function () {
          $("#new_remark").html("");
          $("#map_remarks").removeAttr("data-map-state");
          removeLocation(id);
        });
      }
    );

    map.setActiveArea("activeArea");
    map.setView([added_point.x, added_point.y], map.getZoom());

    $("#map_remarks").attr("data-map-state", "marker-adding");
  }
}

// set marker events
function markerEvents(id) {
  // click
  markers[id].on("click", function (e) {
    map.setActiveArea("activeArea");
    map.setView(e.target.getLatLng(), map.getZoom());

    $(".remark-map-marker").removeClass("remark-map-marker--active");

    let remark_id = $(this)[0].options["id"];
    // console.log(remark_id);
    if (remark_id !== undefined) {
      if ($("#new_remark #remark_" + remark_id).length > 0) {
        // if we click one, that we see already we hide it
        $("#new_remark").html("");
      } else {
        // if we click on any other we switch them
        $("#remark_" + remark_id + "_for_reader").remove(); // remove hidden wcag element
        let href = $("#new_remark").data("show-remark-href") + "/" + remark_id;
        const nonce = $("meta[name=csp-nonce]").attr("content");

        $(e.target._icon)
          .children(".remark-map-marker")
          .addClass("remark-map-marker--active");

        $("#map_remarks").attr("data-map-state", "remark-showing");

        $.ajax({
          method: "GET",
          dataType: "script",
          remote: true,
          url: href,
        }).then(function (data) {
          $.globalEval(data, { nonce });

          $("#new_remark .close-button").click(function () {
            $("#new_remark").html("");
            $("#map_remarks").removeAttr("data-map-state");
            $(".remark-map-marker").removeClass("remark-map-marker--active");
          });
        });
      }
    }
  });

  // drag
  markers[id].on("dragend", function (e) {
    locations[id].lat = e.target.getLatLng().lat;
    locations[id].lng = e.target.getLatLng().lng;

    geocodeLatLng(id);

    const added_point = new Point(
      markers[id].getLatLng()["lat"],
      markers[id].getLatLng()["lng"]
    );

    let isInPolygonArea = true;

    if (coordinates.length > 0) {
      isInPolygonArea = isInside(
        polygon_coords,
        coordinates.length,
        added_point
      );
    }

    handle_new_marker_in_polygon(isInPolygonArea, added_point, id);
  });
}

// gecode LatLng
function geocodeLatLng(id, geocode = true) {
  if (geocode) {
    $.getJSON(
      `${nominatimUrl}/reverse?format=json&lat=${locations[id].lat}&lon=${locations[id].lng}&addressdetails=1`,
      function (json) {
        locations[id].display_name = prepareDisplayName(json);
        locations[id].address = json.address;

        locations[id] &&
          $(`#input-location-${id}`).val(locations[id].display_name);
      }
    );
  }
}

// prepare display name
function prepareDisplayName(obj) {
  return `${obj.address.road || ""} ${obj.address.house_number || ""}, ${
    obj.address.postcode || ""
  } ${obj.address.city || ""}`;
}

// change input value
function changeInputValue(id) {
  const input = $(`#input-location-${id}`);
  locations[id] &&
    input
      .parent()
      .find("input.change")
      .prop(
        "disabled",
        locations[id].display_name.trim() === input.val().trim()
      );
}

// remove location
function removeLocation(id) {
  map.removeLayer(markers[id]);
  delete markers[id];
  delete locations[id];

  $(`#input-location-${id}`).parent().remove();
}

// fullscreen
$(".map-fullscreen-js").on("click", function () {
  const fullscreenTarget = $("#map").parents("section");

  if (fullscreenTarget.hasClass("fullscreen")) {
    window.document.exitFullscreen();
  } else {
    fullscreenTarget[0].requestFullscreen();
    fullscreenTarget.addClass("fullscreen");

    const mapRemarks = $("section.map-remarks");
    $("#followModal").closest(".reveal-overlay").appendTo(mapRemarks);
    $("#map_remarksMapHelpModal").appendTo(mapRemarks);
  }
});

$("#remark_success .close-button").click(function () {
  $("#remark_success").hide();
});

// remove fullscreen class on exit
document.addEventListener("fullscreenchange", function () {
  const fullscreenTarget = $("#map").parents("section");

  if (!document.fullscreenElement) {
    fullscreenTarget.removeClass("fullscreen");
  }
});

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
    map.setView([cord[1], cord[0]], 16);
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

////////////////////////////////////////////////////
//////// checking if point is within polygon
// A Javascript program to check if a given point
// lies inside a given polygon
// Refer https://www.geeksforgeeks.org/check-if-two-given-line-segments-intersect/
// for explanation of functions onSegment(),
// orientation() and doIntersect()

// Given three collinear points p, q, r,
// the function checks if point q lies
// on line segment 'pr'
function onSegment(point, q, r) {
  if (
    q.x <= Math.max(point.x, r.x) &&
    q.x >= Math.min(point.x, r.x) &&
    q.y <= Math.max(point.y, r.y) &&
    q.y >= Math.min(point.y, r.y)
  ) {
    return true;
  }
  return false;
}

// To find orientation of ordered triplet (p, q, r).
// The function returns following values
// 0 --> p, q and r are collinear
// 1 --> Clockwise
// 2 --> Counterclockwise
function orientation(p, q, r) {
  let val = (q.y - p.y) * (r.x - q.x) - (q.x - p.x) * (r.y - q.y);

  if (val == 0) {
    return 0; // collinear
  }
  return val > 0 ? 1 : 2; // clock or counterclock wise
}

// The function that returns true if
// line segment 'p1q1' and 'p2q2' intersect.
function doIntersect(p1, q1, p2, q2) {
  // Find the four orientations needed for
  // general and special cases
  let o1 = orientation(p1, q1, p2);
  let o2 = orientation(p1, q1, q2);
  let o3 = orientation(p2, q2, p1);
  let o4 = orientation(p2, q2, q1);

  // General case
  if (o1 != o2 && o3 != o4) {
    return true;
  }

  // Special Cases
  // p1, q1 and p2 are collinear and
  // p2 lies on segment p1q1
  if (o1 == 0 && onSegment(p1, p2, q1)) {
    return true;
  }

  // p1, q1 and p2 are collinear and
  // q2 lies on segment p1q1
  if (o2 == 0 && onSegment(p1, q2, q1)) {
    return true;
  }

  // p2, q2 and p1 are collinear and
  // p1 lies on segment p2q2
  if (o3 == 0 && onSegment(p2, p1, q2)) {
    return true;
  }

  // p2, q2 and q1 are collinear and
  // q1 lies on segment p2q2
  if (o4 == 0 && onSegment(p2, q1, q2)) {
    return true;
  }

  // Doesn't fall in any of the above cases
  return false;
}

// Returns true if the point p lies
// inside the polygon[] with n vertices
function isInside(polygon, n, p) {
  // There must be at least 3 vertices in polygon[]
  if (n < 3) {
    return false;
  }

  // Create a point for line segment from p to infinite
  let extreme = new Point(INF, p.y);

  // Count intersections of the above line
  // with sides of polygon
  let count = 0,
    i = 0;
  do {
    let next = (i + 1) % n;

    // Check if the line segment from 'p' to
    // 'extreme' intersects with the line
    // segment from 'polygon[i]' to 'polygon[next]'
    if (doIntersect(polygon[i], polygon[next], p, extreme)) {
      // If the point 'p' is collinear with line
      // segment 'i-next', then check if it lies
      // on segment. If it lies, return true, otherwise false
      if (orientation(polygon[i], p, polygon[next]) == 0) {
        return onSegment(polygon[i], p, polygon[next]);
      }

      count++;
    }
    i = next;
  } while (i != 0);

  // Return true if count is odd, false otherwise
  return count % 2 == 1; // Same as (count%2 == 1)
}
// This code is contributed by rag2127

function getUrlParameter(sParam) {
  var sPageURL = window.location.search.substring(1),
    sURLVariables = sPageURL.split("&"),
    sParameterName,
    i;

  for (i = 0; i < sURLVariables.length; i++) {
    sParameterName = sURLVariables[i].split("=");

    if (sParameterName[0] === sParam) {
      return sParameterName[1] === undefined
        ? true
        : decodeURIComponent(sParameterName[1]);
    }
  }
  return false;
}

const remarkIdFromQuery = getUrlParameter("remarkId");
const remarkIdFromPath = (window.location.pathname.match(/remarks\/(\d+)/) ||
  [])[1];

const remarkIdToSelect = remarkIdFromQuery || remarkIdFromPath;

if (remarkIdToSelect) {
  setTimeout(() => {
    const marker = markersRefs.find(
      ({ options }) => options.id == remarkIdToSelect
    );
    if (marker && marker._icon) marker._icon.click();
  }, 500);
}

let fileField, uploadButton, deleteButton, fileBox, fileName;
