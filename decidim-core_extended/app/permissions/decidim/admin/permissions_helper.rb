# frozen_string_literal: true

module Decidim
  module Admin
    module PermissionsHelper

      def current_participatory_space
        @current_participatory_space ||= context.fetch(:current_participatory_space, nil) || context.fetch(:process, nil) || context.fetch(:assembly, nil)
      end

      # Returns a collection of Participatory processes where the given user has the
      # specific role privilege.
      def participatory_processes_with_role_privileges(role)
        Decidim::ParticipatoryProcessesWithUserRole.for(user, role)
      end

      def is_coordinator_in_space?
        return false unless user
        return false unless current_participatory_space
        return false unless user.ad_coordinator?

        if current_participatory_space.is_a?(Decidim::ParticipatoryProcess)
          participatory_processes_with_role_privileges(:admin).include?(current_participatory_space)
        end
      end

    end
  end
end