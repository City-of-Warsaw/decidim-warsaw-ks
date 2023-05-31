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
        if expert.user.avatar.present?
          image_tag expert.avatar.url, style: img_style, alt: "#{t("activemodel.attributes.expert.avatar")} - #{expert.name}"
        elsif expert.avatar.present?
          image_tag expert.avatar.url, style: img_style, alt: "#{t("activemodel.attributes.expert.avatar")} - #{expert.name}"
        else
          image_tag asset_path("decidim/default-avatar.svg"), style: img_style, alt: "#{expert.name}"
        end
      end
    end
  end
end
