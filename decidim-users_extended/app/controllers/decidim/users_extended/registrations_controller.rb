# frozen_string_literal: true

module Decidim::UsersExtended
  class RegistrationsController < Decidim::ApplicationController
    include Decidim::FormFactory
    # helper Decidim::DecidimFormHelper
    # helper Decidim::MetaTagsHelper

    # skip_before_action :current_user
    # skip_before_action :authenticate_user!

    # register_permissions(Decidim::Permissions)

    layout "layouts/decidim/application"

    def check_nickname
      @user_found = !!Decidim::User.find_by(nickname: params[:nickname])
      form = form(Decidim::RegistrationForm).from_params({ nickname: params[:nickname] })
      @banned_word_message = !form.valid? && form.errors[:nickname].any? ? form.errors[:nickname].first : nil
      respond_to do |format|
        format.js
      end
    end

    private

    # def permissions_context
    #   super.merge(
    #     current_participatory_space: try(:current_participatory_space)
    #   )
    # end
    #
    # def permission_class_chain
    #   ::Decidim.permissions_registry.chain_for(::Decidim::Conferences::ApplicationController)
    # end
    #
    # def permission_scope
    #   :public
    # end
  end
end
