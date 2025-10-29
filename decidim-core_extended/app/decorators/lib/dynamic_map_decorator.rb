# frozen_string_literal: true

Decidim::Map::DynamicMap::Builder.class_eval do
  def map_element(html_options = {})
    map_html_options = {
      "role" => "application",
      "aria-label" => "Mapa spotkań, alternatywa tekstowa powyżej",
      "data-decidim-map" => view_options.to_json,
      # The data-markers-data is kept for backwards compatibility
      "data-markers-data" => options.fetch(:markers, []).to_json
    }.merge(html_options)

    content = template.capture { yield }.html_safe if block_given?

    template.content_tag(:div, map_html_options) do
      (content || "")
    end
  end
end
