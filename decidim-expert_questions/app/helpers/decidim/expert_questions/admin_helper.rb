# frozen_string_literal: true

module Decidim
  module ExpertQuestions
    # Custom helpers, scoped to the expert_questions engine.
    #
    module AdminHelper

      def expert_avatar(expert)
        img_style = 'width: 60px;
                     height: 60px;
                     border-radius: 50%;
                     -o-object-fit: cover;
                     object-fit: cover;'
        if expert.avatar.present?
          image_tag(
            Rails.application.routes.url_helpers.rails_representation_path(
              expert.avatar.variant(resize: "100x100^").processed,
              only_path: true,
              style: img_style,
              alt: "#{t("activemodel.attributes.expert.avatar")} - #{expert.full_name}"
            )
          )
        else
          image_pack_tag("media/images/default-avatar.svg", style: img_style, alt: "#{expert.full_name}")
        end
      end
    end
  end
end
