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

    # it used for:
    # - my account
    # - registration new user
    def gender_options_for_profile
      Decidim::User::GENDERS.map { |g| [I18n.t("decidim.users.gender.profile.#{g}"), g] }
    end

    # it used for:
    # - comment
    # - remark
    # - remark on map
    # - user question
    def gender_options_for_public_post
      Decidim::User::GENDERS.map { |g| [I18n.t("decidim.users.gender.public_post.#{g}"), g] }
    end

    def user_districts_for_select
      Decidim::Scope.where.not(scope_type_id: Decidim::ScopeType.citywide_scope_type.id)
                    .map { |a| [translated_attribute(a.name), a.id] }
    end
  end
end
