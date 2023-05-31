# frozen_string_literal: true

require_dependency "decidim/admin_extended/application_controller"

module Decidim::AdminExtended
  # Controller that allows managing all Contact Info Positions at the admin panel.
  class ContactInfoPositionsController < ApplicationController
    layout "decidim/admin/pages"
    helper_method :contact_info_groups

    def index
      enforce_permission_to :update, :organization, organization: current_organization
    end

    def new
      enforce_permission_to :update, :organization, organization: current_organization
      @form = form(Decidim::AdminExtended::ContactInfoPositionForm).instance
    end

    def create
      enforce_permission_to :update, :organization, organization: current_organization
      @form = form(Decidim::AdminExtended::ContactInfoPositionForm).from_params(params)

      Decidim::AdminExtended::CreateContactInfoPosition.call(@form) do
        on(:ok) do
          flash[:notice] = I18n.t(".contact_info_positions.create.success", scope: "decidim.admin_extended")
          redirect_to decidim_admin_extended.contact_info_positions_path
        end

        on(:invalid) do
          flash.now[:alert] = I18n.t(".contact_info_positions.create.errors", scope: "decidim.admin_extended")
          render :new
        end
      end
    end

    def edit
      enforce_permission_to :update, :organization, organization: current_organization
      @form = form(Decidim::AdminExtended::ContactInfoPositionForm).from_model(contact_info_position)
    end

    def update
      enforce_permission_to :update, :organization, organization: current_organization
      @form = form(Decidim::AdminExtended::ContactInfoPositionForm).from_params(params)

      Decidim::AdminExtended::UpdateContactInfoPosition.call(contact_info_position, @form) do
        on(:ok) do
          flash[:notice] = I18n.t(".contact_info_positions.update.success", scope: "decidim.admin_extended")
          redirect_to decidim_admin_extended.contact_info_positions_path
        end

        on(:invalid) do
          flash.now[:alert] = I18n.t(".contact_info_positions.update.errors", scope: "decidim.admin_extended")
          render :edit
        end
      end
    end

    def destroy
      enforce_permission_to :update, :organization, organization: current_organization
      contact_info_position.destroy!
      flash[:notice] = I18n.t(".contact_info_positions.destroy.success", scope: "decidim.admin_extended")
      redirect_to decidim_admin_extended.contact_info_positions_path
    end

    private

    def contact_info_groups
      Decidim::AdminExtended::ContactInfoGroup.sorted_by_weight
    end

    def contact_info_position
      @contact_info_position ||= Decidim::AdminExtended::ContactInfoPosition.find_by(id: params[:id])
    end
  end
end
