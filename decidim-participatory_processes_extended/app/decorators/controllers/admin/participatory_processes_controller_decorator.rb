# frozen_string_literal: true

# Class Decorator - Extending Decidim::ParticipatoryProcesses::Admin::ParticipatoryProcessesController
#
# Decorator implements additional functionalities to the Controller
# and changes existing methods.
Decidim::ParticipatoryProcesses::Admin::ParticipatoryProcessesController.class_eval do
  include Rails.application.routes.mounted_helpers

  helper_method :form_potential_tags

  # Overwritten Decidim method
  #
  # Due to change in permissions: creating processes by ad_coordinators is allowed,
  # but user with this ad_role has no admin permissions to manage process,
  # so he is assigned as process admin, so he can then work on his process.
  def create
    enforce_permission_to :create, :process
    @form = form(Decidim::ParticipatoryProcesses::Admin::ParticipatoryProcessForm).from_params(params)

    Decidim::ParticipatoryProcesses::Admin::CreateParticipatoryProcess.call(@form) do
      on(:ok) do |participatory_process|
        # added method:
        assign_coordinator(participatory_process)
        if current_user.ad_coordinator?
          flash[:notice] = "Nowy wpis został utworzony. Możesz go dalej edytować. Opublikować go może tylko administrator"
          notify_admins(participatory_process)
        else
          flash[:notice] = I18n.t("participatory_processes.create.success", scope: "decidim.admin")
        end
        redirect_to participatory_process_steps_path(participatory_process)
      end

      on(:invalid) do
        flash.now[:alert] = I18n.t("participatory_processes.create.error", scope: "decidim.admin")
        render :new
      end
    end
  end

  private

  def notify_admins(participatory_process)
    Decidim::CoreExtended::TemplatedMailerJob.perform_later('new_process_created_by_coordinator', { resource: participatory_process })
  end

  # Private: assigning current user as process admin.
  #
  # Method also creates ActionLog for role assignment.
  def assign_coordinator(process)
    extra_info = {
      resource: {
        title: current_user.name
      }
    }

    role_params = {
      role: :admin,
      user: current_user,
      participatory_process: process
    }

    Decidim.traceability.create!(
      Decidim::ParticipatoryProcessUserRole,
      current_user,
      role_params,
      extra_info
    )
  end

  def collection
    @collection ||= if current_user.ad_admin?
                      Decidim::ParticipatoryProcess.where(organization: current_organization).latest_first
                    elsif current_user.ad_expert?
                      component_ids = Decidim::ExpertQuestions::Expert.where(decidim_user_id: current_user.id).pluck(:decidim_component_id)
                      Decidim::ParticipatoryProcess.where('decidim_participatory_processes.organization': current_organization)
                                                   .joins(:components).where('decidim_components.id': component_ids).latest_first
                    elsif current_user.ad_moderator? || current_user.ad_coordinator?
                      # bo Decidim::ParticipatoryProcessesWithUserRole.for(current_user) zle zwraca dla .admin?
                      process_ids = Decidim::ParticipatoryProcessUserRole.where(user: current_user).pluck(:decidim_participatory_process_id)
                      Decidim::ParticipatoryProcess.where(id: process_ids).latest_first
                    else
                      # no processes for other roles
                      Decidim::ParticipatoryProcess.none
                    end
  end

  def form_potential_tags
    Decidim::AdminExtended::Tag.order(name: :asc)
  end
end
