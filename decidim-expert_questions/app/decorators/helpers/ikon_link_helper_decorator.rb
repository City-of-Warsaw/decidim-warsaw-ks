# frozen_string_literal: true

Decidim::Admin::IconLinkHelper.class_eval do
  def disabled_icon_link_to(icon_name, link, title, options = {})
    link_to(link,
            method: options[:method],
            class: "action-icon #{options[:class]}",
            data: options[:data] || {},
            title: title,
            disabled: true,
            target: options[:target]) do
      content_tag(:span, data: { tooltip: true, disable_hover: false, click_open: false },
                         title: title) do
        icon(icon_name, aria_label: title, role: "img")
      end
    end
  end
end
