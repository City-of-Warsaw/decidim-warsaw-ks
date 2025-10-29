# frozen_string_literal: true

Decidim::MapHelper.class_eval do

  # OVERWRITTEM public decidim method to fetch proper meeting address
  #
  def static_map_link(resource, options = {}, map_html_options = {}, &)
    return unless resource.geocoded_and_valid?
    return unless map_utility_static || map_utility_dynamic

    lat = resource.is_a?(Decidim::Meetings::Meeting) ? resource.lat : resource.latitude
    lng = resource.is_a?(Decidim::Meetings::Meeting) ? resource.lng : resource.longitude
    address_text = resource.is_a?(Decidim::Meetings::Meeting) ? resource.try(:found_address) : resource.try(:address)
    address_text ||= t("latlng_text", latitude: lat, longitude: lng, scope: "decidim.map.static")
    map_service_brand = t("map_service_brand", scope: "decidim.map.static")



    if map_utility_static
      map_url = map_utility_static.link(
        latitude: lat,
        longitude: lng,
        options:
      )

      # Check that the static map utility actually returns a URL before
      # creating the static map utility. If it does not, the image would be
      # otherwise blank.
      if map_utility_static.url(latitude: resource.latitude, longitude: resource.longitude)
        html_options = {
          class: "static-map leaflet-container leaflet-touch leaflet-fade-anim",
          target: "_blank",
          rel: "noopener",
          id: "area-map",
          data: { "external-link": "text-only" }
        }.merge(map_html_options)
        return link_to(map_url, html_options) do
          # We also add the latitude and the longitude to prevent the Workbox cache to be overly aggressive when updating a map
          image_tag decidim.static_map_path(
            sgid: resource.to_sgid.to_s,
            latitude: lat,
            longitude: lng
          ), alt: "#{map_service_brand} - #{address_text}"
        end
      end
    end

    # Fall back to the dynamic map utility in case static maps are not
    # provided.
    builder = map_utility_dynamic.create_builder(self, {
      type: :static,
      latitude: lat,
      longitude: lng,
      zoom: 15,
      title: "#{map_service_brand} - #{address_text}",
      link: map_url
    }.merge(options))

    builder.map_element(
      { class: "static-map", tabindex: "0" }.merge(map_html_options),
      &
    )
  end

  def dynamic_map_for(options_or_markers = {}, html_options = {}, &)
    return unless map_utility_dynamic

    options = {
      popup_template_id: "marker-popup"
    }
    if options_or_markers.is_a?(Array)
      options[:markers] = options_or_markers
    else
      options = options.merge(options_or_markers)
    end

    builder = map_utility_dynamic.create_builder(self, options)

    map_html_options = { id: "map" }.merge(html_options)
    bottom_id = "#{map_html_options[:id]}_bottom"

    help = content_tag(:div, class: "map__skip-container") do
      sr_content = content_tag(:p, t("screen_reader_explanation", scope: "decidim.map.dynamic"), class: "sr-only")
      link = link_to(t("skip_button", scope: "decidim.map.dynamic"), "##{bottom_id}", class: "map__skip")

      sr_content + link
    end

    map = builder.map_element(map_html_options, &)
    bottom = content_tag(:div, "", id: bottom_id)

    content_tag(:div, help + map + bottom)
  end

  def dynamic_map_for_meetings(options_or_markers = {}, html_options = {}, &block)
    return unless map_utility_dynamic

    options = {
      popup_template_id: "marker-popup"
    }
    if options_or_markers.is_a?(Array)
      options[:markers] = options_or_markers
    else
      options = options.merge(options_or_markers)
    end

    builder = map_utility_dynamic.create_builder(self, options)

    map_html_options = { id: "map" }.merge(html_options)
    bottom_id = "#{map_html_options[:id]}_bottom"

    help = content_tag(:div, class: "map__help") do
      sr_content = content_tag(:p, t("screen_reader_explanation", scope: "decidim.map.dynamic"), class: "show-for-sr")
      link = link_to(t("skip_button", scope: "decidim.map.dynamic"), "##{bottom_id}", class: "skip")

      sr_content + link
    end

    content_tag :div, class: "meetings-map__wrapper area-map", id: "area-map" do
      map = builder.map_element(map_html_options, &block)
      bottom = content_tag(:div, "", id: bottom_id)
      popup = content_tag(:div, "", class: "meetings-map__popup")

      help + map + popup + bottom
    end
  end
  def linked_resources_for(resource, type, link_name)
    linked_resources = resource.linked_resources(type, link_name).group_by { |linked_resource| linked_resource.class.name }

    safe_join(linked_resources.map do |klass, resources|
      resource_manifest = klass.constantize.resource_manifest
      content_tag(:div, class: "section") do
        i18n_name = "#{resource.class.name.demodulize.underscore}_#{resource_manifest.name}"
        content_tag(:h3, I18n.t(i18n_name, scope: "decidim.resource_links.#{link_name}"), class: "section-heading") +
          render(partial: resource_manifest.template, locals: { resources: resources })
      end
    end)
  end
end
