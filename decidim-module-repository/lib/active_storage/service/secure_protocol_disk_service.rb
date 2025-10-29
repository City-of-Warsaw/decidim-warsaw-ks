# frozen_string_literal: true

require 'active_storage/service/disk_service'

module ActiveStorage
  # FIX wrong protocol during blob redirect by setting https protocol
  # setup in file config/storage.yml
  # local:
  #   service: SecureProtocolDisk
  class Service::SecureProtocolDiskService < Service::DiskService
    def url(key, **options)
      Rails.env.development? ? super(key, **options) : super(key, **options).gsub(/http(s)?:/, 'https:')
    end
  end
end