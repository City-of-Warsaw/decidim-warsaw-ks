# frozen_string_literal: true

module Decidim
  module CoreExtended
    # Custom module completes the signature field with the appropriate value, depending on the type of user
    module AuthorForCells
      private

      def author_presenter
        if model.author.is_a?(Decidim::User) && model.author.respond_to?(:has_ad_role?) && model.author.has_ad_role?
          # for registered internal ad users
          Decidim::CoreExtended::AdAuthorPresenter.new(cell: model)
        elsif model.author.is_a?(Decidim::CoreExtended::UnregisteredAuthor)
          # for unregistered users or in case where there is no more author
          Decidim::CoreExtended::UnregisteredAuthorPresenter.new(cell: model)
        else
          # for registered external users
          model.author.presenter
        end
      end
    end
  end
end
