# frozen_string_literal: true

module Decidim
  module ParticipatoryProcessesExtended
    module Admin
      # A form object to create and update Result
      class ResultForm < Form
        include Decidim::Repository::Admin::GalleryInputAttributes
        include Decidim::Repository::Admin::GalleriesValidations

        attribute :name, String
        attribute :body, String
        attribute :weight, Integer
        attribute :added_at, Date
        attribute :participatory_space
        attribute :current_user

        mimic :result

        validates :name, presence: true
        validates :weight, presence: true

        delegate :current_participatory_space, to: :context, prefix: false
        delegate :current_user, to: :context, prefix: false

        alias organization current_organization

        def map_model(model)
          super
          self.gallery_id = model.gallery_id
        end
      end
    end
  end
end
