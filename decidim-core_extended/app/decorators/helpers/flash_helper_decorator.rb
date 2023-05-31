# frozen_string_literal: true

Decidim::DecidimFormHelper.module_eval do

  SIMPLIFIED_KEY_MATCHING = {
    alert:     :alert,
    notice:    :success,
    info:      :success,
    secondary: :success,
    success:   :success,
    error:     :alert,
    warning:   :alert,
    primary:   :success
  }.freeze

  # OVERWRITTEN method adding image before message
  #
  # Displays the flash messages found in ActionDispatch's +flash+ hash using
  # Foundation's +callout+ component.
  #
  # Parameters:
  # * +closable+ - A boolean to determine whether the displayed flash messages
  # should be closable by the user. Defaults to true.
  # * +key_matching+ - A Hash of key/value pairs mapping flash keys to the
  # corresponding class to use for the callout box.
  def display_flash_messages(closable: true, key_matching: {})
    key_matching = FoundationRailsHelper::FlashHelper::DEFAULT_KEY_MATCHING.merge(key_matching)
    key_matching.default = :primary

    capture do
      flash.each do |key, value|
        next if ignored_key?(key.to_sym)
        next if value.blank?

        image = image_tag("flash-#{SIMPLIFIED_KEY_MATCHING[key.to_sym]}.png", alt: '')

        alert_class = key_matching[key.to_sym]
        concat alert_box((image + value).html_safe, alert_class, closable)
      end
    end
  end
end