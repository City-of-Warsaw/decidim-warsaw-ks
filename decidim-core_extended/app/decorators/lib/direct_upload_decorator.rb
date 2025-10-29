# frozen_string_literal: true

ActiveStorage::DirectUploadsController.class_eval do
  before_action do
    # ActiveStorage::Current.host = Rails.env.development? ? request.base_url : "https://#{request.host_with_port}"
    ActiveStorage::Current.url_options = { host: (Rails.env.development? ? request.base_url : "https://#{request.host_with_port}") }
  end
end