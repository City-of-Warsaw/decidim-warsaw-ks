# frozen_string_literal: true

module Decidim
  module CoreExtended
    # Custom helper retrieves author statistic data and generating parameters for commands
    module AuthorParamsBuilder
      attr_accessor :form

      def author_email
        author == unregistered_author ? email : author&.email
      end

      def author_age
        author_age_range
      end

      def author_age_range
        translate_if_present(author_age_value, "age", scope: "decidim.comments")
      end

      def author_gender
        translate_if_present(author_gender_value, "gender.public_post", scope: "decidim.users")
      end

      def author_district
        (author == unregistered_author ? district : author&.district)&.name
      end

      # returns proxy object that serves as Author for objects created by unregistered users
      def unregistered_author
        @unregistered_author ||= Decidim::CoreExtended::UnregisteredAuthor.first
      end

      private

      def author_age_value
        author == unregistered_author ? age : author&.age_range
      end

      def author_gender_value
        author == unregistered_author ? gender : author&.gender
      end

      def translate_if_present(value, key, scope:)
        return nil if value.blank?

        I18n.t("#{key}.#{value}", scope:)
      end

      # second_step_params are filled after creating a content (e.g. comment) in public view
      def author_second_step_params
        if current_user.is_a?(Decidim::User)
          registered_author_params
        else
          unregistered_author_params
        end
      end

      def registered_author_params
        age_range = current_user.age_range.presence || ""

        {
          email: current_user.email,
          age: age_range,
          gender: current_user.gender,
          district_id: current_user.district&.id
        }
      end

      def unregistered_author_params
        {
          email: nil,
          age: form.age,
          gender: form.gender,
          district_id: form.district_id
        }
      end

      # editorial is for registered admin users
      def signature_or_editorial
        return form.signature if author == unregistered_author

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
