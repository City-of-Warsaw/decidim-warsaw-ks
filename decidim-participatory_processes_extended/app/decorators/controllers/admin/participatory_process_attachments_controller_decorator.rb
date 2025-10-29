# frozen_string_literal: true

Decidim::ParticipatoryProcesses::Admin::ParticipatoryProcessAttachmentsController.class_eval do
  def multifiles
    @form = form(Decidim::ParticipatoryProcessesExtended::Admin::MultifileAttachmentsForm).from_params({}, attached_to:)

    render template: "decidim/admin/attachments/multifiles"
  end

  def create_multifiles
    enforce_permission_to(:create, :attachment, attached_to:)

    @form = form(Decidim::ParticipatoryProcessesExtended::Admin::MultifileAttachmentsForm).from_params(params, attached_to:)

    Decidim::ParticipatoryProcessesExtended::Admin::CreateMultifileAttachments.call(@form, attached_to) do
      on(:ok) do
        flash[:notice] = I18n.t("multiple_attachments.create.success", scope: "decidim.admin")
        redirect_to action: :index
      end

      on(:invalid) do
        flash.now[:alert] = I18n.t("multiple_attachments.create.error", scope: "decidim.admin")
        render template: "decidim/admin/attachments/multifiles"
      end
    end
  end
end
