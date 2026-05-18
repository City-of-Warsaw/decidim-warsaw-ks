# frozen_string_literal: true

require_dependency "decidim/custom_proposals/application_controller"

module Decidim::CustomProposals
  class Admin::CustomProposalsController < Decidim::CustomProposals::Admin::ApplicationController
    include Decidim::TranslatableAttributes
    include Decidim::SanitizeHelper
    include Decidim::CoreExtended::SerializerExportHelper

    helper Decidim::ApplicationHelper
    helper_method :custom_proposals, :col_index_to_column_letter

    def index
      enforce_permission_to :read, :custom_proposal
    end

    # controller action for exporting proposals comments data to xls file
    def export
      enforce_permission_to :read, :custom_proposal

      @xml_serializer = Decidim::CustomProposals::CustomProposalCommentsSerializer.new
      @comments = export_comments
      respond_to do |format|
        format.xlsx
      end
    end

    def new
      enforce_permission_to :create, :custom_proposal
      @form = form(Decidim::CustomProposals::Admin::CustomProposalForm).instance
    end

    def create
      enforce_permission_to :create, :custom_proposal
      @form = form(Decidim::CustomProposals::Admin::CustomProposalForm).from_params(params)

      Decidim::CustomProposals::Admin::CreateCustomProposal.call(@form) do
        on(:ok) do
          flash[:notice] = I18n.t("custom_proposals.create.success", scope: "decidim.admin")
          redirect_to custom_proposals_path
        end

        on(:invalid) do
          flash.now[:alert] = I18n.t("custom_proposals.create.errors", scope: "decidim.admin")
          render :new
        end
      end
    end

    def edit
      enforce_permission_to :update, :custom_proposal, custom_proposal: custom_proposal
      @form = form(Decidim::CustomProposals::Admin::CustomProposalForm).from_model(custom_proposal)
    end

    def update
      enforce_permission_to :update, :custom_proposal, custom_proposal: custom_proposal
      @form = form(Decidim::CustomProposals::Admin::CustomProposalForm).from_params(params)

      Decidim::CustomProposals::Admin::UpdateCustomProposal.call(custom_proposal, @form) do
        on(:ok) do
          flash[:notice] = I18n.t("custom_proposals.update.success", scope: "decidim.admin")
          redirect_to custom_proposals_path
        end

        on(:invalid) do
          flash.now[:alert] = I18n.t("custom_proposals.update.errors", scope: "decidim.admin")
          render :edit
        end
      end
    end

    def destroy
      enforce_permission_to :destroy, :custom_proposal, custom_proposal: custom_proposal
      Decidim::CustomProposals::Admin::DestroyCustomProposal.call(custom_proposal, current_user) do
        on(:ok) do
          flash[:notice] = I18n.t("custom_proposals.destroy.success", scope: "decidim.admin")
          redirect_to custom_proposals_path
        end
      end
    end

    private

    def custom_proposals
      @custom_proposals ||= Decidim::CustomProposals::CustomProposal.where(component: current_component).sorted_by_weight.page(params[:page]).per(15)
    end

    def custom_proposal
      @custom_proposal ||= custom_proposals.find params[:id]
    end

    def export_comments
      Decidim::Comments::Comment.where(root_commentable: custom_proposals)
                                .not_hidden
                                .not_deleted
                                .sort_by { |comment| comment.root_commentable.weight }
    end
  end
end
