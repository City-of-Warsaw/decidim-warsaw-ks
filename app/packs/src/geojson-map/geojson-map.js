/**
 * Map Location
 */
import "leaflet-lasso";
import * as turf from "@turf/turf";

var osmUrl = Decidim.config.get("osmUrl") + "/tile/{z}/{x}/{y}.png";
const nominatimUrl = Decidim.config.get("nominatimUrl");

const MapState = {
  SelectParcels: "select-parcels",
  LookupInfo: "lookup-info",
};

const fieldTranslations = {
  nazwa: "Strefa planistyczna",
  oznaczenie: "Oznaczenie",
  profilPodstawowy: "Profil funkcjonalny",
  maksNadziemnaIntensywnoscZabudowy:
    "Maksymalna nadziemna intensywność zabudowy",
  maksUdzialPowierzchniZabudowy: "Maksymalny udział powierzchni zabudowy [%]",
  maksWysokoscZabudowy: "Maksymalna wysokość zabudowy [m]",
  minUdzialPowierzchniBiologicznieCzynnej:
    "Minimalny udział powierzchni biologicznie czynnej [%]",
  OUZ: "Obszar uzupełnienia zabudowy",
  OZS: "Obszar zabudowy śródmiejskiej",
};

const modal = {
  open: function () {
    const $modal = $("[data-map-dialog]");

    $modal.attr("aria-hidden", "false");

    $("[data-note-id]").text(String(window.Decidim.currentDetailedNoteId + 1));

    if (!window.Decidim.studyNoteMap) {
      window.Decidim.initStudyNotesMap();
    } else {
      window.Decidim.studyNoteMap.invalidateSize();
      window.Decidim.studyNoteMapRefreshParcelsLayer(
        window.Decidim.studyNoteMap
      );
    }
  },
  close: function () {
    const $modal = $("[data-map-dialog]");

    $modal.attr("aria-hidden", "true");
  },
};

const $modal = $("[data-map-dialog]");

$modal
  .find("[data-dialog-close], [data-dialog-closable]")
  .on("click", function () {
    modal.close();
  });

window.Decidim.currentDialogs = {
  ...window.Decidim.currentDialogs,
  mapModal: modal,
};

window.Decidim.initStudyNotesMap = function () {
  // set map
  var map = L.map("study-note-map__map", {
    minZoom: 10,
    maxZoom: 18,
    preferCanvas: true,
  }).setView([52.22977, 21.01178], 10);

  window.Decidim.studyNoteMap = map;

  $("#study-note-map__map").removeAttr("tabIndex");

  const OSM = L.tileLayer(osmUrl, {
    attribution:
      '&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors',
  }).addTo(map);

  const Ortofotomapa = L.tileLayer(
    "https://mapa.um.warszawa.pl/mapviewer/mcserver/dane_wawa/ORTO_2023/{z}/{y}/{x}.png",
    {
      maxZoom: 19,
    }
  );

  const overlayLayers = {};

  $("#study-note-map__map").attr("data-map-state", MapState.SelectParcels);

  const layerControl = L.control
    .layers({ OSM, Ortofotomapa }, overlayLayers)
    .addTo(map);

  for (const [concatenatedId, layer] of Object.entries(rasters)) {
    const [id, name] = concatenatedId.split(",");

    layerControl.addOverlay(layer, name);
  }

  const vectorLayers = [];

  L.Control.LoadingIncicator = L.Control.extend({
    onAdd: function (map) {
      const { label } = this.options;

      var div = L.DomUtil.create("div");

      div.className = "leaflet-control-loading-indicator leaflet-control";
      div.innerHTML = `<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" width="16px" height="16px" fill="currentColor"><path d="M18.364 5.63604L16.9497 7.05025C15.683 5.7835 13.933 5 12 5C8.13401 5 5 8.13401 5 12C5 15.866 8.13401 19 12 19C15.866 19 19 15.866 19 12H21C21 16.9706 16.9706 21 12 21C7.02944 21 3 16.9706 3 12C3 7.02944 7.02944 3 12 3C14.4853 3 16.7353 4.00736 18.364 5.63604Z"></path></svg> <span>${label}</span><span data-number></span>`;

      return div;
    },
  });

  L.control.loadingIndicator = function (opts) {
    return new L.Control.LoadingIncicator(opts);
  };

  const loadingIndicatorLayers = L.control.loadingIndicator({
    position: "bottomright",
    label: "Ładowanie podkładów mapowych",
  });

  const loadingIndicatorParcels = L.control.loadingIndicator({
    position: "bottomright",
    label: "Ładowanie działek",
  });

  if (Object.entries(vectors).length > 0) {
    loadingIndicatorLayers.addTo(map);
  }

  for (const [concatenatedId, url] of Object.entries(vectors)) {
    const [id, name] = concatenatedId.split(",");

    if (url.length) {
      $(loadingIndicatorLayers._container)
        .find("[data-number]")
        .html(
          ` (${layerControl._layers.length - Object.keys(rasters).length - 1}/${
            Object.entries(vectors).length
          })`
        );

      fetch(url)
        .then((response) => response.json())
        .then((data) => {
          const layer = L.geoJSON(data, {
            style: function (feature) {
              return {
                color: "#000000",
                weight: 1,
                fillOpacity: 0.75,
                fillColor:
                  feature.properties && feature.properties.fill
                    ? feature.properties.fill
                    : "#cccccc",
                interactive: true,
              };
            },
            onEachFeature: function (feature, layer) {
              if (feature.properties.POPUP) {
                layer.bindTooltip(feature.properties.POPUP, {
                  permanent: false,
                  direction: "center",
                  className: "leaflet-custom-tooltip large",
                  opacity: 1,
                  interactive: false,
                });

                layer.on({
                  click: function (e) {
                    e.originalEvent.preventDefault();
                    e.originalEvent.stopPropagation();
                    e.originalEvent.target.blur();
                  },
                });
              }
            },
          });

          setTimeout(() => {
            $(loadingIndicatorLayers._container)
              .find("[data-number]")
              .html(
                ` (${
                  layerControl._layers.length - Object.keys(rasters).length - 1
                }/${Object.entries(vectors).length})`
              );
          }, 50);

          layerControl.addOverlay(layer, name);
          vectorLayers.push(layer);

          if (
            Object.entries(vectors).length ===
            layerControl._layers.length - Object.keys(rasters).length - 1
          ) {
            setTimeout(() => {
              loadingIndicatorLayers.remove(map);
            }, 300);
          }
        });
    }
  }

  map.attributionControl.setPosition("bottomleft");

  var parcelsLayerGroup = L.layerGroup();

  map.on("zoom", function () {
    var z = map.getZoom();

    if (z > 15) {
      return parcelsLayerGroup.addTo(map);
    }

    return parcelsLayerGroup.removeFrom(map);
  });

  var foundParcelsLayerGroup = L.layerGroup().addTo(map);

  var positionMarkerGroup = L.layerGroup().addTo(map);

  function transformCoordinates(coords) {
    if (Array.isArray(coords[0]) && Array.isArray(coords[0][0])) {
      return coords;
    }

    const pairs = [];
    for (let i = 0; i < coords.length; i += 2) {
      pairs.push([coords[i], coords[i + 1]]);
    }
    return pairs;
  }

  function transformGeometry(geometry) {
    if (geometry.type === "Polygon") {
      return {
        ...geometry,
        coordinates: geometry.coordinates.map((ring) =>
          transformCoordinates(ring)
        ),
      };
    } else if (geometry.type === "MultiPolygon") {
      return {
        ...geometry,
        coordinates: geometry.coordinates.map((polygon) =>
          polygon.map((ring) => transformCoordinates(ring))
        ),
      };
    }
    return geometry;
  }

  async function fetchParcelsData(bounds) {
    const bbox = `${bounds.getWest()},${bounds.getSouth()},${bounds.getEast()},${bounds.getNorth()}`;
    const url = `https://testmapa.um.warszawa.pl/mapviewer/dataserver/DANE_WAWA?t=G_DZIALKI_POBIERANIE_NEW&bbox=${bbox}&to_srid=4326&bbox_srid=4326`;

    try {
      const response = await fetch(url);
      if (!response.ok) {
        throw new Error(`HTTP error! status: ${response.status}`);
      }
      const data = await response.json();
      return data;
    } catch (error) {
      return null;
    } finally {
      loadingIndicatorParcels.remove(map);
    }
  }

  function updateParcelsLayer(geoJsonData) {
    if (!geoJsonData || !geoJsonData.features) {
      return;
    }

    const transformedData = {
      ...geoJsonData,
      features: geoJsonData.features.map((feature) => ({
        ...feature,
        geometry: transformGeometry(feature.geometry),
      })),
    };

    parcelsLayerGroup.clearLayers();

    const newLayer = L.geoJSON(transformedData, {
      onEachFeature: function (feature, layer) {
        if (
          $("#study-note-map__map").attr("data-map-state") ===
          MapState.SelectParcels
        ) {
          layer.on({
            click: function (e) {
              L.DomEvent.stopPropagation(e);

              if (layer.options.color === "#00ff00") {
                window.Decidim.currentParcelId =
                  feature.properties.NAZWA_SERWIS;
                window.Decidim.currentDialogs.parcelDeletionModal.open();

                $("#parcelDeletionModal-description").text(
                  feature.properties._label_
                );
              } else {
                window.Decidim.currentParcelId =
                  feature.properties.NAZWA_SERWIS;
                window.Decidim.currentDialogs.parcelSelectionModal.open();

                $("#parcelSelectionModal-description").text(
                  feature.properties._label_
                );
              }
            },
          });

          layer.bindTooltip(feature.properties.NAZWA_SERWIS, {
            permanent: false,
            direction: "center",
            className: "leaflet-custom-tooltip large",
            opacity: 1,
            interactive: false,
          });

          layer.on({
            click: function (e) {
              e.originalEvent.preventDefault();
              e.originalEvent.stopPropagation();
              e.originalEvent.target.blur();
            },
          });
        }
      },
      style: function (feature) {
        const currentDetailedNoteId = String(
          window.Decidim.currentDetailedNoteId
        );
        const allSelectedParcels = $(
          `[id=detailed_notes_parcel_ids_item_${currentDetailedNoteId}]`
        )
          .map(function () {
            return this.value;
          })
          .get()
          .join(",");

        const parcelIds = allSelectedParcels
          .split(",")
          .map((s) => s.trim())
          .filter((s) => s.length > 0);

        if (parcelIds.includes(feature.properties.NAZWA_SERWIS)) {
          return {
            fill: true,
            fillOpacity: 0.3,
            color: "#00ff00",
            weight: 2,
          };
        }

        return {
          fill: true,
          fillOpacity: 0,
          color: "#ff0000",
          weight: 1,
        };
      },
    });

    newLayer.addTo(parcelsLayerGroup);
  }

  async function refreshParcelsLayer(map) {
    const bounds = map.getBounds();

    const data = await fetchParcelsData(bounds);
    if (data) {
      updateParcelsLayer(data);
    }
  }

  window.Decidim.studyNoteMapRefreshParcelsLayer = refreshParcelsLayer;

  const lassoControl = L.control
    .lasso({
      intersect: true,
      title: "Naciśnij i przeciągnij, żeby zaznaczyć działki",
    })
    .addTo(map)
    .setPosition("topleft");

  L.Control.ClickToSelect = L.Control.extend({
    onAdd: function (map) {
      var button = L.DomUtil.create("a");

      button.className = "leaflet-control-click-to-select";
      button.href = "#";
      button.title = "Wybierz lub usuń działkę / działki poprzez naciśnięcie";
      button.innerHTML = `<svg viewBox="0 0 24 24" width="19px" height="19px" id="ri-arrow-left-up-fill"><path d="M12.361 10.9468L18.0179 16.6037L16.6037 18.0179L10.9468 12.361L5.99707 17.3108V5.99707H17.3108L12.361 10.9468Z"></path></svg>`;

      L.DomEvent.on(button, "click", function (e) {
        L.DomEvent.stopPropagation(e);
        L.DomEvent.preventDefault(e);

        $("#study-note-map__map").attr(
          "data-map-state",
          MapState.SelectParcels
        );
        refreshParcelsLayer(map);

        lassoControl.disable();

        const currentZoom = map.getZoom();

        if (currentZoom < 16) {
          map.setZoom(16);
        }
      });

      const lassoElement = document.getElementsByClassName(
        "leaflet-control-lasso"
      )[0].parentElement;

      lassoElement.prepend(button);

      // add a ghost button to comply with Leaflet's control api
      var ghostButton = L.DomUtil.create("a");

      return ghostButton;
    },
  });

  L.control.clickToSelect = function (opts) {
    return new L.Control.ClickToSelect(opts);
  };

  L.control.clickToSelect().addTo(map);

  L.Control.LookupInfo = L.Control.extend({
    onAdd: function (map) {
      var button = L.DomUtil.create("a");

      button.className = "leaflet-control-lookup-info";
      button.href = "#";
      button.title =
        "Wyświetl informację o ustaleniach planu ogólnego dla danego miejsca";
      button.innerHTML = `<svg width="19px" height="19px" viewBox="0 0 24 24" fill="currentColor"><path d="M12 22C6.47715 22 2 17.5228 2 12C2 6.47715 6.47715 2 12 2C17.5228 2 22 6.47715 22 12C22 17.5228 17.5228 22 12 22ZM12 20C16.4183 20 20 16.4183 20 12C20 7.58172 16.4183 4 12 4C7.58172 4 4 7.58172 4 12C4 16.4183 7.58172 20 12 20ZM11 7H13V9H11V7ZM11 11H13V17H11V11Z"></path></svg>`;

      L.DomEvent.on(button, "click", async function (e) {
        L.DomEvent.stopPropagation(e);
        L.DomEvent.preventDefault(e);

        $("#study-note-map__map").attr("data-map-state", MapState.LookupInfo);

        refreshParcelsLayer(map);

        lassoControl.disable();
      });

      var div = L.DomUtil.create("div");
      div.className = "leaflet-bar leaflet-control";
      div.appendChild(button);

      return div;
    },
  });

  L.control.lookupInfo = function (opts) {
    return new L.Control.LookupInfo(opts);
  };

  L.control.lookupInfo({ position: "topleft" }).addTo(map);

  function setSelectedLayers(layers) {
    layers.forEach((layer) => {
      layer.setStyle({
        fill: true,
        fillOpacity: 0.3,
        color: "#ffff00",
        weight: 2,
      });
    });

    if (layers.length === 1) {
      window.Decidim.currentParcelId =
        layers[0].feature.properties.NAZWA_SERWIS;
    } else {
      window.Decidim.currentParcelIds = layers
        .map((layer) => layer.feature.properties.NAZWA_SERWIS)
        .join(", ");
    }

    window.Decidim.currentDialogs.parcelSelectionModal.open();

    if (layers.length === 1) {
      $("#parcelSelectionModal-description").text(
        layers[0].feature.properties._label_
      );
    } else {
      $("#parcelSelectionModal-description").text(
        `Zaznaczono ${layers.length} działki`
      );
    }
  }

  map.on("lasso.enabled", (event) => {
    $("#study-note-map__map").attr("data-map-state", MapState.SelectParcels);
    refreshParcelsLayer(map);

    const currentZoom = map.getZoom();

    if (currentZoom < 16) {
      map.setZoom(16);
    }
  });

  map.on("lasso.finished", (event) => {
    if (event.layers.length === 0) return;

    setSelectedLayers(event.layers);
  });

  map.on("movestart", async function () {
    const currentZoom = map.getZoom();

    if (currentZoom > 15) {
      loadingIndicatorParcels.addTo(map);
    }
  });

  map.on("moveend", async function () {
    const currentZoom = map.getZoom();

    if (currentZoom > 15) {
      refreshParcelsLayer(map);
    } else {
      loadingIndicatorParcels.remove(map);
    }
  });

  map.on("overlayadd", function (e) {
    const layerName = e.name;

    for (const [concatenatedId, layer] of Object.entries(rasters)) {
      const [id, name] = concatenatedId.split(",");

      if (layer === e.layer) {
        $(`.study-note-map__legend[data-map-background-id='${id}']`).addClass(
          "study-note-map__legend--active"
        );
        break;
      }
    }

    for (const [concatenatedId, url] of Object.entries(vectors)) {
      const [id, name] = concatenatedId.split(",");

      if (layerName === name) {
        $(`.study-note-map__legend[data-map-background-id='${id}']`).addClass(
          "study-note-map__legend--active"
        );
        break;
      }
    }
  });

  map.on("overlayremove", function (e) {
    const layerName = e.name;

    for (const [concatenatedId, layer] of Object.entries(rasters)) {
      const [id, name] = concatenatedId.split(",");

      if (layer === e.layer) {
        $(
          `.study-note-map__legend[data-map-background-id='${id}']`
        ).removeClass("study-note-map__legend--active");
        break;
      }
    }

    for (const [concatenatedId, url] of Object.entries(vectors)) {
      const [id, name] = concatenatedId.split(",");

      if (layerName === name) {
        $(
          `.study-note-map__legend[data-map-background-id='${id}']`
        ).removeClass("study-note-map__legend--active");
        break;
      }
    }
  });

  map.on("click", function (e) {
    if (
      $("#study-note-map__map").attr("data-map-state") === MapState.LookupInfo
    ) {
      let popupContent = "";
      const clickedPoint = turf.point([e.latlng.lng, e.latlng.lat]);

      popupContent += `<table class="w-full">`;
      let combinedProps = {};

      vectorLayers.forEach(function (layer) {
        layer.eachLayer(function (featureLayer) {
          if (
            featureLayer.feature &&
            turf.booleanPointInPolygon(clickedPoint, featureLayer.feature)
          ) {
            const props = featureLayer.feature.properties || {};

            combinedProps = { ...combinedProps, ...props };
          }
        });
      });

      for (var key in fieldTranslations) {
        popupContent += `<tr class="${
          ["OZS", "OUZ"].includes(key) ? "border-t-2 border-black/40" : ""
        }">
          <th class="px-3 py-2 !text-xs w-1/2">${
            fieldTranslations[key] ?? key
          }</th>
          <td class="px-3">
            ${
              combinedProps[key] !== null &&
              combinedProps[key] !== undefined &&
              combinedProps[key] !== ""
                ? key === "profilPodstawowy"
                  ? `${combinedProps["profilPodstawowy"]}${
                      combinedProps["profilDodatkowy"] &&
                      `,${combinedProps["profilDodatkowy"]}`
                    }`
                  : combinedProps[key]
                : ["OZS", "OUZ"].includes(key)
                ? "NIE"
                : ""
            }
          </td>
        </tr>`;
      }

      popupContent += "</table>";

      if (popupContent !== `<table class="w-full"></table>`) {
        L.popup({ maxHeight: 400 })
          .setLatLng(e.latlng)
          .setContent(popupContent)
          .openOn(map);
      }
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

      positionMarkerGroup.clearLayers();

      // sets the view of the map
      map.setView([cord[1], cord[0]], 17);

      L.circle([cord[1], cord[0]], 25.0, {
        color: "#0251fa",
        fillColor: "#0251fa",
        opacity: 0.2,
        fillOpacity: 0.2,
      }).addTo(positionMarkerGroup);

      L.circle([cord[1], cord[0]], 5.0, {
        color: "#0251fa",
        fillColor: "#0251fa",
        fillOpacity: 1,
      }).addTo(positionMarkerGroup);
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

  $("button.auto-clear").click(function (e) {
    positionMarkerGroup.clearLayers();
  });

  async function fetchParcelByNrObrAndNrDz(nrObr, nrDz) {
    const alteredNrDz = nrDz.split("/")[0]; // Get only the first part of nrDz – the service doesn't accept nrDz with slashes
    const response = await fetch(
      `/mapa-um/GraniceDzialek/findByNrObrAndNrDz/${nrObr}/${alteredNrDz}`
    );

    const geoJson = await response.json();

    if (geoJson.type === "Feature") {
      return geoJson;
    } else if (geoJson.type === "FeatureCollection") {
      return geoJson.features.find(
        (feature) => feature.properties.nrDz === nrDz.toString()
      );
    } else {
      return null;
    }
  }

  $(".obr-dz-wrapper .auto-clear").click(function () {
    foundParcelsLayerGroup.clearLayers();
    $("#nrObr").val("");
    $("#nrDz").val("");
    $("#nrDz").parent().removeClass("obr-dz-wrapper__input--clearable");
  });

  $("#nrObr, #nrDz").keydown(function (event) {
    if (event.which === 13) $("#obr-dz-button").click();
  });

  $("#obr-dz-button").click(async function () {
    foundParcelsLayerGroup.clearLayers();

    $("#obr-dz-error").text("");
    $("#nrObr").removeClass("is-invalid-input");
    $("#nrDz").removeClass("is-invalid-input");
    $(".obr-dz-wrapper").removeClass("obr-dz-wrapper--error");

    if ($("#nrObr").val().length < 5) {
      $("#obr-dz-error").text("Podaj prawidłowy numer obrębu (min. 5 znaków)");
      $("#nrObr").addClass("is-invalid-input");
      $(".obr-dz-wrapper").addClass("obr-dz-wrapper--error");
      return;
    }

    if ($("#nrDz").val().length === 0) {
      $("#obr-dz-error").text("Wypełnij numer działki");
      $("#nrDz").addClass("is-invalid-input");
      $(".obr-dz-wrapper").addClass("obr-dz-wrapper--error");
      return;
    }

    $("#obr-dz-button").addClass("auto-is-loading");

    try {
      const data = await fetchParcelByNrObrAndNrDz(
        $("#nrObr").val(),
        $("#nrDz").val()
      );

      const layer = L.geoJSON(data, {
        style: function () {
          return {
            fill: true,
            fillOpacity: 0.2,
            color: "#0251fa",
            weight: 2,
          };
        },
      });

      layer.addTo(foundParcelsLayerGroup);

      map.setView(layer.getBounds().getCenter(), 17);

      $("#nrDz").parent().addClass("obr-dz-wrapper__input--clearable");
    } catch (error) {
      $("#obr-dz-error").text("Nie znaleziono działki");
      $("#nrObr").addClass("is-invalid-input");
      $("#nrDz").addClass("is-invalid-input");
      $(".obr-dz-wrapper").addClass("obr-dz-wrapper--error");
    }

    $("#obr-dz-button").removeClass("auto-is-loading");
  });

  $("[data-action='add-parcel-to-note']").click(function () {
    const selectedNoteId = String(window.Decidim.currentDetailedNoteId);
    const currentParcelId = window.Decidim.currentParcelId;
    const currentParcelIds = window.Decidim.currentParcelIds;

    if (selectedNoteId && currentParcelId) {
      const selectedRemarkParcelsInput = $(
        `#detailed_notes_parcel_ids_item_${selectedNoteId}`
      );

      selectedRemarkParcelsInput.val(function (i, val) {
        if (val) {
          const parcels = val.split(",").map((s) => s.trim());
          if (!parcels.includes(currentParcelId)) {
            parcels.push(currentParcelId);
          }
          return parcels.join(", ");
        } else {
          return currentParcelId;
        }
      });

      selectedRemarkParcelsInput.trigger("change");
    }

    if (selectedNoteId && currentParcelIds) {
      const selectedRemarkParcelsInput = $(
        `#detailed_notes_parcel_ids_item_${selectedNoteId}`
      );

      selectedRemarkParcelsInput.val(function (i, val) {
        if (val) {
          const parcels = val.split(",").map((s) => s.trim());
          currentParcelIds.split(",").forEach((id) => {
            if (!parcels.includes(id.trim())) {
              parcels.push(id.trim());
            }
          });
          return parcels.join(", ");
        } else {
          return currentParcelIds;
        }
      });

      selectedRemarkParcelsInput.trigger("change");
    }

    refreshParcelsLayer(map);

    window.Decidim.currentDialogs.parcelSelectionModal.close();

    window.Decidim.currentParcelId = null;
    window.Decidim.currentParcelIds = null;
  });

  $(
    "[data-action='cancel-parcel-selection'], , #parcelSelectionModal [data-dialog-closable]"
  ).click(function () {
    refreshParcelsLayer(map);

    window.Decidim.currentParcelId = null;
    window.Decidim.currentParcelIds = null;
  });

  $("[data-action='remove-parcel-from-note']").click(function () {
    const selectedNoteId = String(window.Decidim.currentDetailedNoteId);
    const currentParcelId = window.Decidim.currentParcelId;

    if (selectedNoteId && currentParcelId) {
      const selectedRemarkParcelsInput = $(
        `#detailed_notes_parcel_ids_item_${selectedNoteId}`
      );

      selectedRemarkParcelsInput.val(function (i, val) {
        if (val) {
          const parcels = val.split(",").map((s) => s.trim());
          const updatedParcels = parcels.filter((p) => p !== currentParcelId);
          return updatedParcels.join(", ");
        } else {
          return val;
        }
      });

      selectedRemarkParcelsInput.trigger("change");
    }

    refreshParcelsLayer(map);

    window.Decidim.currentDialogs.parcelDeletionModal.close();

    window.Decidim.currentParcelId = null;
  });
};
