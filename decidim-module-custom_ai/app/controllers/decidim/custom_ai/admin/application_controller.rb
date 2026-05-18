# frozen_string_literal: true

module Decidim
  module CustomAi
    module Admin
      # This controller is the abstract class from which all other controllers of
      # this engine inherit.
      #
      # Note that it inherits from `Decidim::Admin::Components::BaseController`, which
      # override its layout and provide all kinds of useful methods.
      class ApplicationController < Decidim::Admin::Components::BaseController
        helper_method :decidim_custom_ai
        before_action :enforce_manage_ai_permission
        before_action :check_ai_files_for_component

        def permission_class_chain
          [::Decidim::CustomAi::Admin::Permissions] + super
        end

        def user_not_authorized_path
          decidim.root_path
        end

        def user_has_no_permission_path
          decidim.root_path
        end

        def current_component
          @current_component ||= Decidim::Component.find(params[:component_id])
        end

        def current_participatory_space
          current_component.participatory_space
        end

        def enforce_manage_ai_permission
          enforce_permission_to :manage_ai_functions, :component, component: current_component
        end

        def check_ai_files_for_component
          unless Decidim::CustomAi::File.where(component: current_component).any?
            flash.now[:alert] = I18n.t("files.check.error", scope: "decidim.custom_ai", link_to_add_file: decidim_custom_ai_admin.new_file_path)
          end
        end

      end
    end
  end
end
