# frozen_string_literal: true

module Decidim
  module Repository
    module Admin
      class FolderForm < Form
        attribute :name, String

        validates :name, presence: true, length: { maximum: 60 }

        mimic :folder

        alias organization current_organization
      end
    end
  end
end
