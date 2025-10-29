document.addEventListener("DOMContentLoaded", function() {
  new window.Autocomplete(".filter_address", {
    // default selects the first item in
    // the list of results
    selectFirst: true,

    // The number of characters entered should start searching
    howManyCharacters: 5,

    // onSearch
    onSearch: ({ currentValue }) => {
      const nominatimUrl = Decidim.config.get('nominatimUrl');
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
    onSubmit: ({ object }) => {
      const cord = object.geometry.coordinates;

      $('.filter_address_lat').val(cord[1]);
      $('.filter_address_lng').val(cord[0]);
      $('form.new_filter').submit();
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

  const searchBar = $(".filter_address");
  const clearButton = $('button.auto-clear[type="button"][aria-label="clear text from input"]');

  if (searchBar.val().trim() !== "") {
    clearButton.removeClass("hidden");
  } else {
    clearButton.addClass("hidden");
  }

  clearButton.on("click", () => {
    searchBar.val("");
    clearButton.addClass("hidden");
  });
});
