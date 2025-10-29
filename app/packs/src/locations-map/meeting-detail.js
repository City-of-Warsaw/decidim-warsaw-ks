$(document).ready(function () {
  const $mapEl = $("#area-map");
  if ($mapEl.length > 0) {
    $mapEl.on("click", function () {
      const lat = $mapEl.data("lat");
      const lng = $mapEl.data("lng");
      const zoom = 16;
      const url = `https://www.openstreetmap.org/?mlat=${lat}&mlon=${lng}#map=${zoom}/${lat}/${lng}`;
      window.open(url, "_blank");
    });
  }
});
