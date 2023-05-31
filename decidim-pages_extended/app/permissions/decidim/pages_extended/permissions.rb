# frozen_string_literal: true

module Decidim
  module PagesExtended
    class Permissions < Decidim::Admin::Permissions

      def permissions
        return permission_action if permission_action.scope != :admin

        coorinator_actions?
        publish_page_action?

        # allow! if (user.admin? || user.ad_admin?) && admin_terms_accepted?
        allow! if (user.ad_admin?)

        permission_action
      end

      private

      def coorinator_actions?
        return unless permission_action.action == :read ||
                      permission_action.action == :manage ||
                      permission_action.action == :enter ||
                      permission_action.action == :create ||
                      permission_action.action == :update

        toggle_allow(user.ad_admin? || can_manage_space?(role: :admin))
      end

      def publish_page_action?
        return unless permission_action.action == :publish

        toggle_allow(user.ad_admin?)
      end

      # from Decidim::Admin::Permissions
      def can_manage_space?(role: :any)
        return unless user
        return unless current_participatory_space
        return unless user.ad_admin? || user.ad_coordinator?

        if current_participatory_space.is_a?(Decidim::ParticipatoryProcess)
          participatory_processes_with_role_privileges(role).include?(current_participatory_space)
        elsif current_participatory_space.is_a?(Decidim::Assemmbly)
          assemblies_with_role_privileges(role).include?(current_participatory_space)
        end
      end

      # Returns a collection of Participatory processes where the given user has the
      # specific role privilege.
      def participatory_processes_with_role_privileges(role)
        user_roles = ParticipatoryProcessUserRole.where(user: user, role: role)
        Decidim::ParticipatoryProcessesWithUserRole.for(user, role)
      end

      def assemblies_with_role_privileges(role)
        Decidim::Assemblies::AssembliesWithUserRole.for(user, role)
      end

      def current_participatory_space
        @current_participatory_space ||= context.fetch(:current_participatory_space, nil) || context.fetch(:process, nil) || context.fetch(:assembly, nil)
      end

      # def page
      #   @page ||= context.fetch(:page, nil)
      # end
    end
  end
end
