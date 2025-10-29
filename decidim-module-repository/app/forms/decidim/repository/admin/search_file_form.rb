# frozen_string_literal: true

module Decidim
  module Repository
    module Admin
      class SearchFileForm < Form
        attribute :name, String

        mimic :search_file

        alias organization current_organization
      end
    end
  end
end
