# frozen_string_literal: true

Decidim::SearchResourceFieldsMapper.class_eval do
  private

  # overwritten method
  # removed strip_tags from 
  def read_i18n_field(resource, locale, field_name)
    content = read_field(resource, @declared_fields, field_name)
    return if content.nil?

    content = Array.wrap(content).collect do |item|
      text = if item.is_a?(Hash)
               item[locale].presence || item.dig("machine_translations", locale) || ""
             else
               item
             end

      if text.is_a?(String)
        Decidim::ContentProcessor.render_without_format(text, links: false)
      else
        text
      end
    end

    content.respond_to?(:join) ? content.join(" ") : content
  end
end
