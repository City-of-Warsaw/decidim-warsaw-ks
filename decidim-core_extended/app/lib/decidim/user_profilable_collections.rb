# frozen_string_literal: true
module Decidim
  module UserProfilableCollections
    include TranslatableAttributes

    def user_age_for_select
      Decidim::User::AGE_RANGES.map do |g|
        [
          I18n.t("age.#{g}", scope: "decidim.comments"),
          g
        ]
      end
    end

    def user_gender_for_select
      Decidim::User::GENDERS.map do |g|
        [
          I18n.t("gender.#{g}", scope: "decidim.users"),
          g
        ]
      end
    end

    def user_districts_for_select
      Decidim::Scope.where.not(scope_type_id: Decidim::ScopeType.citywide_scope_type.id)
                    .map { |a| [translated_attribute(a.name), a.id] }
    end
  end
end
