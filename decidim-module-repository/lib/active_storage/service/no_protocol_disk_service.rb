# frozen_string_literal: true

require 'active_storage/service/disk_service'

module ActiveStorage
  # FIX wrong protocol during blob redirect by removing protocol
  # setup in file config/storage.yml
  # local:
  #   service: NoProtocolDisk
  class Service::NoProtocolDiskService < Service::DiskService
    def url(key, **options)
      super(key, **options).gsub(/http(s)?:/, '')
    end
  end
end