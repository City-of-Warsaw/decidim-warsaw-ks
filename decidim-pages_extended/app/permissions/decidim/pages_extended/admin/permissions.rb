# frozen_string_literal: true

module Decidim
  module PagesExtended
    module Admin
      class Permissions < Decidim::Admin::Permissions
        include Decidim::Admin::PermissionsHelper

        def permissions
          return permission_action if permission_action.scope != :admin

          allowed_page_action?
          allowed_pages_action?

          permission_action
        end

        private

        def page
          @page ||= context.fetch(:page, nil)
        end

        def allowed_page_action?
          return unless permission_action.subject == :page
          return unless page

          case permission_action.action
          when :publish
            toggle_allow(user.ad_admin?)
          when :update, :destroy
            toggle_allow(user.ad_admin? || can_manage_space?(role: :admin) && !current_participatory_space.published?)
          else
            toggle_allow(user.ad_admin?)
          end
        end

        def allowed_pages_action?
          return unless permission_action.subject == :page
          return if page

          case permission_action.action
          when :read
            toggle_allow(user.ad_admin? || can_manage_space?(role: :admin))
          when :create
            toggle_allow(user.ad_admin? || can_manage_space?(role: :admin) && !current_participatory_space.published?)
          when :update
            # zarzadzanie komponentem
            toggle_allow(user.ad_admin? || can_manage_space?(role: :admin))
          else
            toggle_allow(user.ad_admin?)
          end
        end

        # from Decidim::Admin::Permissions
        def can_manage_space?(role: :any)
          return unless user
          return unless current_participatory_space
          return unless user.ad_admin? || user.ad_coordinator?

          case current_participatory_space
          when Decidim::ParticipatoryProcess
            participatory_processes_with_role_privileges(role).include?(current_participatory_space)
          when Decidim::Assemmbly
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
end

