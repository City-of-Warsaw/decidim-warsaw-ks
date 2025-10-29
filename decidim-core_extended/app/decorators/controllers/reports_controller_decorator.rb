# frozen_string_literal: true

Decidim::ReportsController.class_eval do
  # overwritten method
  # swap flash notice translation on :ok
  def create
    enforce_permission_to :create, :moderation

    @form = form(Decidim::ReportForm).from_params(params, can_hide: reportable.try(:can_be_administered_by?, current_user))

    Decidim::CreateReport.call(@form, reportable) do
      on(:ok) do
        flash[:notice] = I18n.t("decidim.reports.create.success_create")
        redirect_to reportable.reload.reported_content_url
      end

      on(:invalid) do
        flash[:alert] = I18n.t("decidim.reports.create.error")
        redirect_back fallback_location: root_path
      end
    end
  end

  private

  # overwritten method
  # extended method
  # add scenarios
  # when report concerns about comment belongs to information that is separate space with separate permissions
  # when report concerns about one of 3 custom components:
  # - Decidim::Remarks::Remark
  # - Decidim::ConsulationMap::Remark
  # - Decidim::ExpertQuestions::UserQuestion
  # then use participatory_space permissions
  def permission_class_chain
    reportable_permissions_class =
      if reportable.respond_to?(:root_commentable)
        if reportable.root_commentable.is_a?(Decidim::News::Information)
          Decidim::News::Permissions
        else
          reportable.participatory_space.manifest.permissions_class
        end
      else
        reportable.participatory_space.manifest.permissions_class
      end

    [reportable_permissions_class, Decidim::Permissions]
  end
end
