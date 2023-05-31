# frozen_string_literal: true

module Decidim::WsNotification
  class WsMessage < ApplicationRecord
    include Decidim::Traceable
    include Decidim::Loggable
    self.table_name = 'decidim_ws_messages'

    serialize :district_ids, Array

    belongs_to :user,
               foreign_key: 'decidim_user_id',
               class_name: 'Decidim::User'
    belongs_to :organization,
               foreign_key: 'decidim_organization_id',
               class_name: 'Decidim::Organization'

    validates :valid_date_from, presence: true
    validates :valid_date_to, presence: true
    validates :category_id, presence: true
    # validates :district_ids, presence: true

    scope :latest_first, -> { order(created_at: :desc) }


    def published?
      !!published_at
    end

    def mark_as_published
      update_column(:published_at, DateTime.current)
    end
  end
end
