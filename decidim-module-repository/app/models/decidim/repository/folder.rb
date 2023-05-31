# frozen_string_literal: true

module Decidim::Repository
  class Folder < ApplicationRecord

    belongs_to :creator,
               foreign_key: 'creator_id',
               class_name: 'Decidim::User'
    belongs_to :organization,
               foreign_key: 'decidim_organization_id',
               class_name: 'Decidim::Organization'
    has_many :files, dependent: :nullify

    validates :name, presence: true

    scope :latest_first, -> { order(created_at: :desc) }
    scope :alphabetical, -> { order(name: :asc) }

  end
end
