# frozen_string_literal: true

module Decidim
  module CoreExtended
    # Custom helper retrieves user statistic data and generating parameters for commands
    module RegisteredUserHelper
      # second_step_params are filled after creating a content (e.g. comment) in public view
      def second_step_params
        age_range = current_user.age_range.presence || ""

        {
          signature: signature_or_editorial,
          email: current_user.email,
          age: age_range,
          gender: current_user.gender,
          district_id: current_user.district.present? ? current_user.district.id : nil
        }
      end

      # editorial is for registered admin users
      def signature_or_editorial
        if current_user.respond_to?(:has_ad_role?) && current_user.has_ad_role?
          # if no editorial then default ad user signature
          current_user.editorial.presence || I18n.t("decidim.author.ad_user")
        else
          current_user.name
        end
      end
    end
  end
end
