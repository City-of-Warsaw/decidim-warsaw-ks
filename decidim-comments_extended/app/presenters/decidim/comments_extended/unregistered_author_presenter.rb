# frozen_string_literal: true

module Decidim
  module CommentsExtended
    #
    # A dummy presenter to abstract out the unregistered author.
    #
    class UnregisteredAuthorPresenter < Decidim::OfficialAuthorPresenter
      def initialize(params = {})
        @name_param = params[:name_param]
        @signature = params[:signature]
      end

      def blocked?
        false
      end

      def name
        case @name_param
        when 'mail'
          I18n.t("decidim.comments_extended.models.comment.fields.unregistered_author_mail")
        when 'signed'
          @signature
        when 'ad_user'
          I18n.t("decidim.comments_extended.models.comment.fields.ad_user")
        when 'ad_user_remark'
          I18n.t("decidim.comments_extended.models.comment.fields.ad_user_remark")
        when 'ad_user_question'
          I18n.t("decidim.comments_extended.models.comment.fields.ad_user_question")
        else
          I18n.t("decidim.comments_extended.models.comment.fields.unregistered_author")
        end
      end
    end
  end
end
