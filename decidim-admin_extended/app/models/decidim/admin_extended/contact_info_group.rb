# frozen_string_literal: true

module Decidim::AdminExtended
  # Contact Info Group groups contact info positions
  class ContactInfoGroup < ApplicationRecord
    has_many :contact_info_positions

    scope :published, -> { where(published: true)}
    scope :sorted_by_weight, -> { order(:weight)}
  end
end
