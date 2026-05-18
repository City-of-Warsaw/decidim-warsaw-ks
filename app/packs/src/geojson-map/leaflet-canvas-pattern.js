// https://github.com/bgx1012/leaflet-polygon-fillPattern-canvas

(function (window, document, undefined) {
  if (L.Canvas) {
    L.Canvas.include({
      _fillStroke: function (ctx, layer) {
        var options = layer.options;

        if (options.fill) {
          ctx.globalAlpha = options.fillOpacity;
          ctx.fillStyle = options.fillColor || options.color;

          ctx.fill(options.fillRule || "evenodd");
        }

        if (options.stroke && options.weight !== 0) {
          if (ctx.setLineDash) {
            ctx.setLineDash((layer.options && layer.options._dashArray) || []);
          }

          ctx.globalAlpha = options.opacity;
          ctx.lineWidth = options.weight;
          ctx.strokeStyle = options.color;
          ctx.lineCap = options.lineCap;
          ctx.lineJoin = options.lineJoin;
          ctx.stroke();
          if (options.patternId) {
            var img = document.getElementById(options.patternId);
            ctx.save();
            ctx.clip();
            var bounds = layer._rawPxBounds;
            var size = bounds.getSize();
            var pattern = ctx.createPattern(img, "repeat");
            ctx.fillStyle = pattern;
            ctx.fillRect(bounds.min.x, bounds.min.y, size.x, size.y);
            ctx.restore();
          }
        }
      },
    });
  }
})(this, document);
