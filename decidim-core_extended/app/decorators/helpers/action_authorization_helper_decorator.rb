# frozen_string_literal: true

Decidim::ActionAuthorizationHelper.module_eval do
  private

  # OVERWRITTEN: add followModal
  # rubocop: disable Metrics/PerceivedComplexity
  def authorized_to(tag, action, arguments, block)
    if block
      body = block
      url = arguments[0]
      html_options = arguments[1]
    else
      body = arguments[0]
      url = arguments[1]
      html_options = arguments[2]
    end

    html_options ||= {}
    resource = html_options.delete(:resource)

    if action == :follow
      html_options = clean_authorized_to_data_open(html_options)

      html_options["data-open"] = "followModal"
      url = "#"
    elsif !current_user
      html_options = clean_authorized_to_data_open(html_options)

      html_options["data-open"] = "loginModal"
      url = "#"
    elsif action && !action_authorized_to(action, resource: resource).ok?
      html_options = clean_authorized_to_data_open(html_options)

      html_options["data-open"] = "authorizationModal"
      html_options["data-open-url"] = modal_path(action, resource)
      url = "#"
    end

    html_options["onclick"] = "event.preventDefault();" if url == ""

    if block
      send("#{tag}_to", url, html_options, &body)
    else
      send("#{tag}_to", body, url, html_options)
    end
  end
  # rubocop: enable Metrics/PerceivedComplexity
end