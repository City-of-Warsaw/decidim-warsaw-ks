/**
 * Map Location
 */
import "leaflet-lasso";
import * as turf from "@turf/turf";

import "./leaflet-canvas-pattern";

var osmUrl = Decidim.config.get("osmUrl") + "/tile/{z}/{x}/{y}.png";
const nominatimUrl = Decidim.config.get("nominatimUrl");

const MapState = {
  SelectParcels: "select-parcels",
  LookupInfo: "lookup-info",
};

const fieldTranslations = {
  nazwa: "Strefa planistyczna",
  oznaczenie: "Oznaczenie",
  profilPodstawowy: "Profil funkcjonalny podstawowy",
  profilDodatkowy: "Profil funkcjonalny dodatkowy",
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
  opener: null,
  open: function (opener) {
    const $modal = $("[data-map-dialog]");

    $modal.attr("aria-hidden", "false");

    $("[data-note-id]").text(String(window.Decidim.currentDetailedNoteId + 1));

    const focusableElements = $modal.find(
      'a[href], area[href], input:not([disabled]), select:not([disabled]), textarea:not([disabled]), button:not([disabled]), iframe, object, embed, [tabindex="0"], [contenteditable]'
    );

    const firstElement = focusableElements[0];
    firstElement.focus();

    if (!window.Decidim.studyNoteMap) {
      if (window.Decidim.currentDialogs.mapGuideModal) {
        window.Decidim.currentDialogs.mapGuideModal.open();
        window.Decidim.currentDialogs.mapGuideModal.firstFocusableElement.focus();
      }

      window.Decidim.initStudyNotesMap();
    } else {
      window.Decidim.studyNoteMap.invalidateSize();
      window.Decidim.studyNoteMapRefreshParcelsLayer(
        window.Decidim.studyNoteMap
      );
    }

    this.opener = opener;
  },
  close: function () {
    const $modal = $("[data-map-dialog]");

    $modal.attr("aria-hidden", "true");

    if (this.opener) {
      this.opener.focus();
    }
  },
};

const $modal = $("[data-map-dialog]");

$modal
  .find("[data-dialog-close], [data-dialog-closable]")
  .on("click", function () {
    modal.close();
  });

$modal.on("keydown", function (event) {
  if (event.key === "Escape") {
    modal.close();

    if (modal.opener) {
      modal.opener.focus();
    }
  } else if (event.key === "Tab") {
    const focusableElements = $modal.find(
      'a[href], area[href], input:not([disabled]), select:not([disabled]), textarea:not([disabled]), button:not([disabled]), iframe, object, embed, [tabindex="0"], [contenteditable]'
    );

    const firstElement = focusableElements[0];
    const lastElement = focusableElements[focusableElements.length - 1];
    if (event.shiftKey) {
      if (document.activeElement === firstElement) {
        event.preventDefault();
        lastElement.focus();
      }
    } else {
      if (document.activeElement === lastElement) {
        event.preventDefault();
        firstElement.focus();
      }
    }
  }
});

window.Decidim.currentDialogs = {
  ...window.Decidim.currentDialogs,
  mapModal: modal,
};

window.Decidim.initStudyNotesMap = function () {
  // set map
  var map = L.map("study-note-map__map", {
    minZoom: 10,
    maxZoom: 19,
    preferCanvas: true,
  }).setView([52.22977, 21.01178], 10);

  window.Decidim.studyNoteMap = map;

  $("#study-note-map__map").removeAttr("tabIndex");

  const OSM = L.tileLayer(osmUrl, {
    maxZoom: 19,
    attribution:
      '&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors',
  }).addTo(map);

  const Ortofotomapa = L.tileLayer(
    "https://mapa.um.warszawa.pl/mapviewer/mcserver/dane_wawa/ORTO_2023/{z}/{y}/{x}.png",
    {
      maxZoom: 19,
    }
  );

  const rasters = mapBackgrounds.filter((bg) => bg.fileType === "raster");
  const vectors = mapBackgrounds.filter((bg) => bg.fileType === "vector");

  const overlayLayers = {};

  const parcelsNumbersLayer = L.tileLayer.wms(
    "https://wms2.um.warszawa.pl/geoserver/WMS/wms?",
    {
      layers: "numery_dzialek",
      transparent: true,
      format: "image/png",
      maxZoom: 19,
      minZoom: 17,
      minNativeZoom: 19,
    }
  );

  parcelsNumbersLayer.addTo(map);

  $("#study-note-map__map").attr("data-map-state", MapState.SelectParcels);

  const layerControl = L.control
    .layers({ OSM, Ortofotomapa }, overlayLayers, {
      autoZIndex: false,
      sortLayers: true,
      sortFunction: function (layerA, layerB, layerNameA, layerNameB) {
        const mapBackgroundA = mapBackgrounds.find(
          (bg) => bg.name === layerNameA
        );
        const mapBackgroundB = mapBackgrounds.find(
          (bg) => bg.name === layerNameB
        );

        const positionA = mapBackgroundA ? mapBackgroundA.position : 0;
        const positionB = mapBackgroundB ? mapBackgroundB.position : 0;

        return positionA > positionB ? 1 : -1;
      },
    })
    .addTo(map);

  const rasterLayers = [];

  for (const background of rasters) {
    const {
      id,
      name,
      url,
      filePath,
      xLatitude,
      xLongitude,
      yLatitude,
      yLongitude,
      position,
      visibleOnLoad,
      minZoomLevel,
    } = background;

    const layer = L.imageOverlay(
      filePath,
      [
        [xLatitude, xLongitude],
        [yLatitude, yLongitude],
      ],
      {
        zIndex: position * 1000,
        minZoom: minZoomLevel || 0,
      }
    );

    layerControl.addOverlay(layer, name);
    rasterLayers.push({ id, layer });

    if (visibleOnLoad && minZoomLevel <= map.getZoom()) {
      layer.addTo(map);
    }
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

  if (vectors.length > 0) {
    loadingIndicatorLayers.addTo(map);
  }

  for (const background of vectors) {
    const { id, name, filePath, position, visibleOnLoad, minZoomLevel } =
      background;

    if (filePath.length) {
      $(loadingIndicatorLayers._container)
        .find("[data-number]")
        .html(
          ` (${layerControl._layers.length - rasters.length - 2}/${
            vectors.length
          })`
        );

      fetch(filePath)
        .then((response) => response.json())
        .then((data) => {
          const { decidimMapPattern } = data;

          const layer = L.geoJSON(data, {
            style: function (feature) {
              return {
                color: decidimMapPattern ? "#888888" : "#000000",
                weight: decidimMapPattern ? 4 : 1,
                fillOpacity: decidimMapPattern ? 0 : 0.75,
                fillColor:
                  feature.properties && feature.properties.fill
                    ? feature.properties.fill
                    : "#cccccc",
                interactive: true,
                ...(decidimMapPattern && { dashArray: "30 10" }),
              };
            },
            pointToLayer: function (feature, latlng) {
              return L.marker(latlng, {
                icon: L.divIcon({
                  className: "my-div-icon",
                  html:
                    feature.properties && feature.properties.symbol
                      ? feature.properties.symbol
                      : "",
                }),
              });
            },
            onEachFeature: function (feature, layer) {
              if (decidimMapPattern) {
                layer.options.patternId = decidimMapPattern.toLowerCase();
              }

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
            minZoom: minZoomLevel || 0,
          });

          setTimeout(() => {
            $(loadingIndicatorLayers._container)
              .find("[data-number]")
              .html(
                ` (${layerControl._layers.length - rasters.length - 2}/${
                  vectors.length
                })`
              );
          }, 50);

          layerControl.addOverlay(layer, name);
          vectorLayers.push({ id, layer });

          if (visibleOnLoad && minZoomLevel <= map.getZoom()) {
            layer.addTo(map);
          }

          if (
            vectors.length ===
            layerControl._layers.length - rasters.length - 2
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

    const rastersToHide = rasters.filter(
      (bg) => bg.minZoomLevel && bg.minZoomLevel > z
    );

    const vectorsToHide = vectors.filter(
      (bg) => bg.minZoomLevel && bg.minZoomLevel > z
    );

    [...rastersToHide, ...vectorsToHide].forEach((bg) => {
      const rasterLayer = rasterLayers.find((rl) => rl.id === bg.id);
      const vectorLayer = vectorLayers.find((vl) => vl.id === bg.id);

      if (rasterLayer) {
        rasterLayer.layer.removeFrom(map);
      }

      if (vectorLayer) {
        vectorLayer.layer.removeFrom(map);
      }
    });

    if (z > 16) {
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
            MapState.SelectParcels &&
          !lassoControl.enabled()
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
    newLayer.bringToFront();
    parcelsNumbersLayer.bringToFront();
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

        if (currentZoom < 17) {
          map.setZoom(17);
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

  L.Control.GuideModal = L.Control.extend({
    onAdd: function (map) {
      var button = L.DomUtil.create("a");

      button.className = "leaflet-control-guide-modal";
      button.href = "#";
      button.title = "Pokaż instrukcję korzystania z mapy";
      button.innerHTML = `<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" width="19px" height="19px"><path d="M12 22C6.47715 22 2 17.5228 2 12C2 6.47715 6.47715 2 12 2C17.5228 2 22 6.47715 22 12C22 17.5228 17.5228 22 12 22ZM12 20C16.4183 20 20 16.4183 20 12C20 7.58172 16.4183 4 12 4C7.58172 4 4 7.58172 4 12C4 16.4183 7.58172 20 12 20ZM11 15H13V17H11V15ZM13 13.3551V14H11V12.5C11 11.9477 11.4477 11.5 12 11.5C12.8284 11.5 13.5 10.8284 13.5 10C13.5 9.17157 12.8284 8.5 12 8.5C11.2723 8.5 10.6656 9.01823 10.5288 9.70577L8.56731 9.31346C8.88637 7.70919 10.302 6.5 12 6.5C13.933 6.5 15.5 8.067 15.5 10C15.5 11.5855 14.4457 12.9248 13 13.3551Z"></path></svg>`;

      L.DomEvent.on(button, "click", function (e) {
        L.DomEvent.stopPropagation(e);
        L.DomEvent.preventDefault(e);

        window.Decidim.currentDialogs.mapGuideModal.open();
        window.Decidim.currentDialogs.mapGuideModal.firstFocusableElement.focus();
      });

      var div = L.DomUtil.create("div");
      div.className = "leaflet-bar leaflet-control";
      div.appendChild(button);

      return div;
    },
  });

  L.control.guideModal = function (opts) {
    return new L.Control.GuideModal(opts);
  };

  if (window.Decidim.currentDialogs.mapGuideModal) {
    L.control.guideModal({ position: "topleft" }).addTo(map);
  }

  map.on("lasso.enabled", (event) => {
    $("#study-note-map__map").attr("data-map-state", MapState.SelectParcels);
    window.Decidim.currentParcelId = null;
    refreshParcelsLayer(map);

    const currentZoom = map.getZoom();

    if (currentZoom < 17) {
      map.setZoom(17);
    }
  });

  map.on("lasso.finished", (event) => {
    if (event.layers.length === 0) return;

    const parcelLayers = event.layers.filter((layer) => {
      return "NAZWA_SERWIS" in layer.feature.properties;
    });

    setSelectedLayers(parcelLayers);
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

    for (const background of rasterLayers) {
      const { id, layer } = background;

      if (layer === e.layer) {
        $(`.study-note-map__legend[data-map-background-id='${id}']`).addClass(
          "study-note-map__legend--active"
        );
        break;
      }
    }

    for (const background of vectors) {
      const { id, name } = background;

      if (layerName === name) {
        $(`.study-note-map__legend[data-map-background-id='${id}']`).addClass(
          "study-note-map__legend--active"
        );
        break;
      }
    }

    const layers = [...rasterLayers, ...vectorLayers]
      .sort((a, b) => {
        const mapBackgroundA = mapBackgrounds.find((bg) => bg.id === a.id);
        const mapBackgroundB = mapBackgrounds.find((bg) => bg.id === b.id);

        const positionA = mapBackgroundA ? mapBackgroundA.position : 0;
        const positionB = mapBackgroundB ? mapBackgroundB.position : 0;

        return positionA > positionB ? 1 : -1;
      })
      .map(({ layer }) => {
        layer.bringToFront();
      });

    refreshParcelsLayer(map);
  });

  map.on("overlayremove", function (e) {
    const layerName = e.name;

    for (const background of rasterLayers) {
      const { id, layer } = background;

      if (layer === e.layer) {
        $(
          `.study-note-map__legend[data-map-background-id='${id}']`
        ).removeClass("study-note-map__legend--active");
        break;
      }
    }

    for (const background of vectors) {
      const { id, name } = background;

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

      vectorLayers.forEach(function ({ layer }) {
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
                ? combinedProps[key]
                : ["OZS", "OUZ"].includes(key)
                ? "NIE"
                : "nie określono"
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
    "[data-action='cancel-parcel-selection'], #parcelSelectionModal [data-dialog-closable]"
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

  window.Decidim.currentDialogs.parcelSelectionModal.config.onClose =
    function () {
      refreshParcelsLayer(map);
      $("#mapModal-content > [data-dialog-closable]").focus();
    };

  window.Decidim.currentDialogs.parcelDeletionModal.config.onClose =
    function () {
      $("#mapModal-content > [data-dialog-closable]").focus();
    };

  window.Decidim.currentDialogs.parcelSelectionModal.config.onOpen =
    function () {
      $("#parcelSelectionModal-content > [data-dialog-closable]").focus();
    };

  window.Decidim.currentDialogs.parcelDeletionModal.config.onOpen =
    function () {
      $("#parcelDeletionModal-content > [data-dialog-closable]").focus();
    };

  if (window.Decidim.currentDialogs.mapGuideModal) {
    window.Decidim.currentDialogs.mapGuideModal.config.onClose = function () {
      $("#mapModal-content > [data-dialog-closable]").focus();
    };

    window.Decidim.currentDialogs.mapGuideModal.config.onOpen = function () {
      $("#mapGuideModal-content > [data-dialog-closable]").focus();
    };
  }
};
