# frozen_string_literal: true

module Decidim
  module CoreExtended
    class CoauthorshipsCell < Decidim::CoauthorshipsCell
      def show
        if authorable?
          cell "decidim/author", presenter_for_author(model), extra_classes.merge(has_actions: has_actions?, from: model)
        else
          cell(
            "decidim/collapsible_authors",
            presenters_for_identities(model),
            cell_name: "decidim/author",
            cell_options: extra_classes,
            size: size,
            from: model,
            has_actions: has_actions?
          )
        end
      end      
    end
  end
end
