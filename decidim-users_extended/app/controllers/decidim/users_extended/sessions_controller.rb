# frozen_string_literal: true

module Decidim::UsersExtended
  class SessionsController < Decidim::ApplicationController
    include Decidim::FormFactory
    helper Decidim::DecidimFormHelper
    helper Decidim::MetaTagsHelper

    # skip_before_action :current_user
    # skip_before_action :authenticate_user!
    skip_before_action :verify_authenticity_token, only: :peum_callback

    # register_permissions(Decidim::Permissions)

    # layout "layouts/decidim/application"
    layout "layouts/decidim/admin/login"

    def new
      @form = form(Decidim::UsersExtended::AdminSessionForm).instance
    end

    def create
      @form = form(Decidim::UsersExtended::AdminSessionForm).from_params(params[:admin_session])

      Decidim::UsersExtended::CreateAdminSession.call(@form) do
        on(:ok) do |user|
          sign_in(:user, user)

          flash[:notice] = I18n.t("admin_session.create.success", scope: "decidim.ad_access")
          redirect_to decidim_admin.root_path
        end

        on(:invalid) do
          flash.now[:alert] = I18n.t("admin_session.create.error", scope: "decidim.ad_access")
          render :new
        end
      end
    end

    def peum_login
      redirect_to Decidim::UsersExtended::PeumService.new.peum_url
    end

    def peum_callback
      Decidim::UsersExtended::PeumService.call(params[:code]) do
        on(:ok) do |user_info|
          user = find_or_create_user(user_info)
          if user
            sign_in(:user, user)
            flash[:notice] = 'Zalogowano pomyślnie'
          else
            flash[:error] = 'Niepoprawne dane logowania'
          end
        end

        on(:invalid) do
          flash[:error] = 'Niepoprawne dane logowania'
        end
        redirect_to decidim.root_path
      end
    end

    private

    def find_or_create_user(user_info)
      email = user_info['email']
      return unless email

      user = Decidim::User.find_by email: email
      return user if user

      given_name = user_info['given_name']
      family_name = user_info['family_name']
      generated_password = SecureRandom.hex 16

      user = Decidim::User.new(
        tos_agreement: true,
        accepted_tos_version: Time.current, # TODO: jak sie nie zaakceptuje warunkow to niestety bedzie redirect do ponownej autoryzacji
        email: email,
        name: "#{given_name} #{family_name}".presence || "User#{Time.current.to_i}",
        nickname: "user-#{Time.current.to_i}",
        # display_name: "user-#{Time.current.to_i}", # todo: dopytac czy nie zmianiac tego jak ktos wyrazil zgode!
        # first_name: given_name,
        # last_name: family_name,
        password: generated_password,
        password_confirmation: generated_password,
        organization: Decidim::Organization.first,
        locale: 'pl',
        # anonymous_number: rand(Time.current.to_i), # Tylko BO
        # wylaczamy zapraszanie https://www.py4u.net/discuss/1231180
        skip_invitation: true, # to nie potrzebne
        confirmed_at: Time.current # to zapewnie, ze potwierdzenie konta nie jest wysylane
      )

      if user.save
        user
      else
        nil
      end
    end

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
