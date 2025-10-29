((exports) => {
  const L = exports.L; // eslint-disable-line

  L.DivIcon.SVGIcon.DecidimIcon = L.DivIcon.SVGIcon.extend({
    // Improved version of the _createSVG, essentially the same as in later
    // versions of Leaflet. It adds the `px` values after the width and height
    // CSS making the focus borders work correctly across all browsers.
    _createSVG: function() {
      const path = this._createPath();
      const circle = this._createCircle();
      const text = this._createText();
      const className = `${this.options.className}-svg`;

      const style = `width:${this.options.iconSize.x}px; height:${this.options.iconSize.y}px;`;

      const svg = `<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 30.367 41.924" version="1.1" class="${className}" style="${style}">
                    <g id="Component_90_248" data-name="Component 90 – 248" transform="translate(0)">
                      <g id="Component_88" data-name="Component 88" transform="translate(0 0)">
                        <path id="Subtraction_18" data-name="Subtraction 18" d="M15.183,0A15.2,15.2,0,0,0,0,15.183c0,10.39,13.587,25.643,14.166,26.288a1.368,1.368,0,0,0,2.034,0c.579-.644,14.166-15.9,14.166-26.288A15.2,15.2,0,0,0,15.183,0Z" fill="#2f81b7" fill-rule="evenodd"/>
                      </g>
                      <circle id="Ellipse_85" data-name="Ellipse 85" cx="5" cy="5" r="5" transform="translate(10.21 9.002)" fill="#fff"/>
                    </g>
                  </svg>`;

      return svg;
    }
  });
})(window);
