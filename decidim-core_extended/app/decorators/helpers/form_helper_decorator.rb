# frozen_string_literal: true

Decidim::DecidimFormHelper.module_eval do

  def base_error_messages(record)
    return unless record.respond_to?(:errors)
    return unless record.errors[:base].any?

    alert_box(record.errors.full_messages_for(:base).join(","), "alert", false)
  end
end