/**
 * Map
 */

function panToShowPopupAboveMarker(map, latlng, offsetRatio = 0.35) {
  const mapHeight = map.getSize().y;
  const offsetY = mapHeight * offsetRatio;
  const targetPoint = map
    .project(latlng, map.getZoom())
    .subtract([0, -offsetY]);
  const targetLatLng = map.unproject(targetPoint, map.getZoom());

  map.setView(targetLatLng, map.getZoom(), { animate: true });
}

function initMeetingsMap(selector) {
  let map_element = $("#" + selector);
  $("a.leaflet-popup-close-button").removeAttr("href");
  if (map_element.length === 0) return;

  var osmUrl = Decidim.config.get("osmUrl") + "/tile/{z}/{x}/{y}.png";
  var loadingAddressText = "Wczytywanie adresu...";

  var locations = {};
  var markers = {};

  const container = L.DomUtil.get(selector);
  if (container && container._leaflet_id != null) {
    container._leaflet_id = null;
  }

  // set map
  var map = L.map(selector, {
    minZoom: 10,
    maxZoom: 18,
    gestureHandling: true,
  }).setView([52.22977, 21.01178], 11);

  if (window.innerWidth > 640) {
    map.setActiveArea("activeArea", {
      position: "absolute",
      top: "0px",
      left: "0px",
      bottom: "0px",
      right: "400px",
    });
  }

  map_element.removeAttr("tabIndex");

  L.tileLayer(osmUrl, {
    attribution:
      '&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors',
  }).addTo(map);

  map.on("click", revertMarkers);
  map.attributionControl.setPosition("bottomleft");

  var OfflineClosedIcon = L.Icon.extend({
    options: {
      iconUrl: Decidim.config.get("markerOfflineClosedIconUrl"),
      iconRetinaUrl: Decidim.config.get("markerOfflineClosedIconRetinaUrl"),
      shadowUrl: Decidim.config.get("markerShadowUrl"),
      iconSize: [25, 41],
      iconAnchor: [12, 41],
      popupAnchor: [1, -34],
      tooltipAnchor: [16, -28],
      shadowSize: [41, 41],
    },
  });

  var ActiveOfflineClosedIcon = L.Icon.extend({
    options: {
      iconUrl: Decidim.config.get("markerOfflineClosedIconUrl"),
      iconRetinaUrl: Decidim.config.get("markerOfflineClosedIconRetinaUrl"),
      shadowUrl: Decidim.config.get("markerShadowUrl"),
      iconSize: [35, 60],
      iconAnchor: [15, 55],
      popupAnchor: [1, -34],
      tooltipAnchor: [16, -28],
      shadowSize: [41, 41],
    },
  });

  var ActiveOfflineClosedMobileIcon = L.Icon.extend({
    options: {
      iconUrl: Decidim.config.get("markerOfflineClosedIconUrl"),
      iconRetinaUrl: Decidim.config.get("markerOfflineClosedIconRetinaUrl"),
      shadowUrl: Decidim.config.get("markerShadowUrl"),
      iconSize: [35, 60],
      iconAnchor: [15, 55],
      popupAnchor: [1, -34],
      tooltipAnchor: [16, -28],
      shadowSize: [41, 41],
    },
  });

  var OfflineClosedIcon = L.Icon.extend({
    options: {
      iconUrl: Decidim.config.get("markerOfflineClosedIconUrl"),
      iconRetinaUrl: Decidim.config.get("markerOfflineClosedIconRetinaUrl"),
      shadowUrl: Decidim.config.get("markerShadowUrl"),
      iconSize: [25, 41],
      iconAnchor: [15, 55],
      popupAnchor: [1, -34],
      tooltipAnchor: [16, -28],
      shadowSize: [41, 41],
    },
  });

  var ActiveOfflineIcon = L.Icon.extend({
    options: {
      iconUrl: Decidim.config.get("markerOfflineActiveIconUrl"),
      iconRetinaUrl: Decidim.config.get("markerOfflineActiveIconRetinaUrl"),
      shadowUrl: Decidim.config.get("markerShadowUrl"),
      iconSize: [35, 60],
      iconAnchor: [15, 55],
      popupAnchor: [1, -34],
      tooltipAnchor: [16, -28],
      shadowSize: [41, 41],
    },
    _getIconUrl: function (name) {
      return L.Icon.prototype._getIconUrl.call(this, name);
    },
  });

  var OfflineClosedMobileIcon = L.Icon.extend({
    options: {
      iconUrl: Decidim.config.get("markerOfflineClosedIconUrl"),
      iconRetinaUrl: Decidim.config.get("markerOfflineClosedIconRetinaUrl"),
      shadowUrl: Decidim.config.get("markerShadowUrl"),
      iconSize: [70, 120],
      iconAnchor: [30, 110],
      popupAnchor: [2, -68],
      tooltipAnchor: [32, -56],
      shadowSize: [82, 82],
    },
  });

  var OnlineClosedIcon = L.Icon.extend({
    options: {
      iconUrl: Decidim.config.get("markerOnlineClosedIconUrl"),
      iconRetinaUrl: Decidim.config.get("markerOnlineClosedIconRetinaUrl"),
      shadowUrl: Decidim.config.get("markerShadowUrl"),
      iconSize: [25, 41],
      iconAnchor: [12, 41],
      popupAnchor: [1, -34],
      tooltipAnchor: [16, -28],
      shadowSize: [41, 41],
    },
  });

  var ActiveOnlineClosedIcon = L.Icon.extend({
    options: {
      iconUrl: Decidim.config.get("markerOnlineClosedIconUrl"),
      iconRetinaUrl: Decidim.config.get("markerOnlineClosedIconRetinaUrl"),
      shadowUrl: Decidim.config.get("markerShadowUrl"),
      iconSize: [35, 60],
      iconAnchor: [15, 55],
      popupAnchor: [1, -34],
      tooltipAnchor: [16, -28],
      shadowSize: [41, 41],
    },
  });

  var OnlineClosedMobileIcon = L.Icon.extend({
    options: {
      iconUrl: Decidim.config.get("markerOnlineClosedIconUrl"),
      iconRetinaUrl: Decidim.config.get("markerOnlineClosedIconRetinaUrl"),
      shadowUrl: Decidim.config.get("markerShadowUrl"),
      iconSize: [70, 120],
      iconAnchor: [30, 110],
      popupAnchor: [2, -68],
      tooltipAnchor: [32, -56],
      shadowSize: [82, 82],
    },
  });

  // Offline meeting icon
  var OfflineIcon = L.Icon.extend({
    options: {
      iconUrl: Decidim.config.get("markerOfflineIconUrl"),
      iconRetinaUrl: Decidim.config.get("markerOfflineIconRetinaUrl"),
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

  var ActiveOfflineIcon = L.Icon.extend({
    options: {
      iconUrl: Decidim.config.get("markerOfflineActiveIconUrl"),
      iconRetinaUrl: Decidim.config.get("markerOfflineActiveIconRetinaUrl"),
      shadowUrl: Decidim.config.get("markerShadowUrl"),
      iconSize: [35, 60],
      iconAnchor: [15, 55],
      popupAnchor: [1, -34],
      tooltipAnchor: [16, -28],
      shadowSize: [41, 41],
    },
    _getIconUrl: function (name) {
      return L.Icon.prototype._getIconUrl.call(this, name);
    },
  });

  var ActiveOfflineMobileIcon = L.Icon.extend({
    options: {
      iconUrl: Decidim.config.get("markerOfflineActiveIconUrl"),
      iconRetinaUrl: Decidim.config.get("markerOfflineActiveIconRetinaUrl"),
      shadowUrl: Decidim.config.get("markerShadowUrl"),
      iconSize: [35, 60],
      iconAnchor: [15, 55],
      popupAnchor: [1, -34],
      tooltipAnchor: [16, -28],
      shadowSize: [41, 41],
    },
    _getIconUrl: function (name) {
      return L.Icon.prototype._getIconUrl.call(this, name);
    },
  });

  // Online meeting icon
  var OnlineIcon = L.Icon.extend({
    options: {
      iconUrl: Decidim.config.get("markerOnlineIconUrl"),
      iconRetinaUrl: Decidim.config.get("markerOnlineIconRetinaUrl"),
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

  var ActiveOnlineIcon = L.Icon.extend({
    options: {
      iconUrl: Decidim.config.get("markerOnlineActiveIconUrl"),
      iconRetinaUrl: Decidim.config.get("markerOnlineActiveIconRetinaUrl"),
      shadowUrl: Decidim.config.get("markerShadowUrl"),
      iconSize: [35, 60],
      iconAnchor: [15, 55],
      popupAnchor: [1, -34],
      tooltipAnchor: [16, -28],
      shadowSize: [41, 41],
    },
    _getIconUrl: function (name) {
      return L.Icon.prototype._getIconUrl.call(this, name);
    },
  });

  var ActiveOnlineMobileIcon = L.Icon.extend({
    options: {
      iconUrl: Decidim.config.get("markerOnlineActiveIconUrl"),
      iconRetinaUrl: Decidim.config.get("markerOnlineActiveIconRetinaUrl"),
      shadowUrl: Decidim.config.get("markerShadowUrl"),
      iconSize: [70, 120],
      iconAnchor: [30, 110],
      popupAnchor: [2, -68],
      tooltipAnchor: [32, -56],
      shadowSize: [82, 82],
    },
    _getIconUrl: function (name) {
      return L.Icon.prototype._getIconUrl.call(this, name);
    },
  });

  var offlineIcon = new OfflineIcon();
  var activeOfflineIcon = new ActiveOfflineIcon();
  var activeOfflineMobileIcon = new ActiveOfflineMobileIcon();
  var offlineClosedIcon = new OfflineClosedIcon();
  var offlineClosedMobileIcon = new OfflineClosedMobileIcon();
  var activeOfflineClosedIcon = new ActiveOfflineClosedIcon();
  var activeOfflineClosedMobileIcon = new ActiveOfflineClosedMobileIcon();

  var onlineIcon = new OnlineIcon();
  var activeOnlineIcon = new ActiveOnlineIcon();
  var activeOnlineMobileIcon = new ActiveOnlineMobileIcon();
  var onlineClosedIcon = new OnlineClosedIcon();
  var activeOnlineClosedIcon = new ActiveOnlineClosedIcon();
  var onlineClosedMobileIcon = new OnlineClosedMobileIcon();

  let map_data_el = map_element.find('[role="application"]');
  let raw_data = map_data_el.data("decidim-map");
  let meetings_data =
    typeof raw_data === "string" ? JSON.parse(raw_data) : raw_data;

  var clusters = L.markerClusterGroup({
    chunkedLoading: true,
    showCoverageOnHover: false,
    maxClusterRadius: 20,
  });

  let meetings_locations = [];

  if (meetings_data.markers && Array.isArray(meetings_data.markers)) {
    meetings_locations = meetings_data.markers;
  } else if ("latitude" in meetings_data && "longitude" in meetings_data) {
    meetings_locations = [meetings_data];
  }

  if (meetings_locations.length === 1) {
    const only = meetings_locations[0];
    map.setView([only.latitude, only.longitude], only.zoom || 15, {
      animate: false,
    });
  }

  if (meetings_locations.length > 0) {
    var bounds = [];

    $.each(meetings_locations, function (k, v) {
      if (!v.latitude || !v.longitude) return;

      addMarker(
        {
          latlng: {
            lat: v.latitude,
            lng: v.longitude,
          },
          title: v.title,
          address: v.address,
          ...v,
        },
        k
      );
      bounds.push([v.latitude, v.longitude]);
    });

    map.addLayer(clusters);
  }

  function clickZoom(e) {
    const latlng = e.target.getLatLng();
    const offsetY = map.getSize().y * -0.2;

    const point = map.project(latlng, map.getZoom()).subtract([0, -offsetY]);
    const newLatLng = map.unproject(point, map.getZoom());

    map.setView(newLatLng, map.getZoom(), { animate: true });
  }

  function revertMarkers() {
    $(".meetings-map__popup").html("");
    $.each(markers, function (itemK, itemV) {
      let icon;

      if (locations[itemK].past) {
        icon =
          locations[itemK].meetingType === "online"
            ? onlineClosedIcon
            : offlineClosedIcon;
      } else {
        icon =
          locations[itemK].meetingType === "online" ? onlineIcon : offlineIcon;
      }

      markers[itemK].setIcon(icon);
    });
  }

  // add marker
  function addMarker(e, id = Date.now()) {
    locations[id] = {
      lat: e.latitude,
      lng: e.longitude,
      title: e.title || null,
      address: e.address || null,
      ...e,
    };

    var icon;
    if (e.past) {
      icon = e.meetingType === "online" ? onlineClosedIcon : offlineClosedIcon;
    } else {
      icon = e.meetingType === "online" ? onlineIcon : offlineIcon;
    }

    var content = `<div class="map-info__content map-meeting-card ${
      e.area && !e.past ? `area-color-${e.areaId}` : ""
    } ${e.past ? "past-meeting" : ""}">
                    <div class="map-meeting-card__close-bar map-meeting-card__close"></div>
                    <img class="map-meeting-card__close-icon map-meeting-card__close" tabIndex="0" src="${Decidim.config.get(
                      "closeIconBlackUrl"
                    )}" />

                    <div class="">
                      <a href="${e.link}" class="meeting-title">
                        <h3>${e.title}</h3>

                        <span class="fill"></span>
                      </a>
                    </div>

                    ${e.processTitle}

                    <hr>

                    <ul class="ul-reset" role="list">
                      <li class="map-meeting-card__item">
                        <img class="map-meeting-card__item-icon" src="${Decidim.config.get(
                          "calendarIconGrayUrl"
                        )}" alt="" />
                        <div class="map-meeting-card__item-text">
                          <strong>
                            ${e.startDate}, ${e.weekDay} ${e.startTime}
                          </strong>
                        </div>

                        ${
                          e.meetingType == "online" || e.meetingType == "hybrid"
                            ? `<img class="map-meeting-card__item-icon" src="${Decidim.config.get(
                                "computerIconGrayUrl"
                              )}" alt="" />
                          <div class="map-meeting-card__item-text">
                            <strong>ONLINE</strong>
                          </div>`
                            : ""
                        }
                      </li>

                      ${
                        e.meetingType == "in_person" ||
                        e.meetingType == "hybrid"
                          ? `<li class="map-meeting-card__item">
                          <img class="map-meeting-card__item-icon" src="${Decidim.config.get(
                            "mapPinIconGrayUrl"
                          )}" alt="" />
                          <div class="map-meeting-card__item-text">
                             <strong>${e.location}</strong> ${e.locationDetails}
                          </div>
                        </li>`
                          : ""
                      }
                    </ul>

                    <div class="map-meeting-card__buttons">
                      <button class="button small hollow map-meeting-card__close">Zamknij</button>
                      <a href="${
                        e.link
                      }" class="button small">Pokaż spotkanie</a>
                    </div>
                  </div>`;

    markers[id] = new L.marker(e.latlng, {
      icon: icon,
      alt: e.title,
    })
      .addTo(clusters)
      .bindPopup(content)
      .on("click", function (e_) {
        revertMarkers();

        var activeIcon;
        if (window.innerWidth <= 640) {
          activeIcon = e.past
            ? e.meetingType === "online"
              ? activeOnlineClosedMobileIcon
              : activeOfflineClosedMobileIcon
            : e.meetingType === "online"
            ? activeOnlineMobileIcon
            : activeOfflineMobileIcon;
        } else {
          activeIcon = e.past
            ? e.meetingType === "online"
              ? activeOnlineClosedIcon
              : activeOfflineClosedIcon
            : e.meetingType === "online"
            ? activeOnlineIcon
            : activeOfflineIcon;
        }

        markers[id].setIcon(activeIcon);
        clickZoom(e_);

        $(".meetings-map__popup").html(content);
        $(".meetings-map__popup .map-meeting-card__close").click(function () {
          $(".meetings-map__popup").html("");
          revertMarkers();
        });
      });

    markers[id].getPopup().on("remove", revertMarkers);
  }

  if (meetings_locations.length == 1) {
    markers[Object.keys(markers)[0]].off("click");
  }

  $("[data-meeting-index]").on("click", function () {
    map.closePopup();

    let targetMarker = markers[$(this).data("meeting-index")];
    let visibleParentMarker = clusters.getVisibleParent(targetMarker);

    if (!visibleParentMarker || !visibleParentMarker._icon) {
      map.panTo(targetMarker.getLatLng());
    }

    if (window.innerWidth <= 640) {
      const rect = document.querySelector("#area-map").getBoundingClientRect();
      const offset = 280;

      window.scrollTo({
        top: window.pageYOffset + rect.top - offset,
        behavior: "smooth",
      });
    }
    
    panToShowPopupAboveMarker(map, targetMarker.getLatLng());

    visibleParentMarker._icon.click();
  });
}

$(document).ready(function () {
  initMeetingsMap("area-map");
});
