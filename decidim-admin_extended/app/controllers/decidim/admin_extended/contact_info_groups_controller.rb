# frozen_string_literal: true

require_dependency "decidim/admin_extended/application_controller"

module Decidim::AdminExtended
  # Controller that allows managing all Contact Info Groups at the admin panel.
  class ContactInfoGroupsController < ApplicationController
    include Decidim::Admin::Concerns::HasTabbedMenu
    layout 'decidim/admin/static_pages'
    helper_method :contact_info_groups

    add_breadcrumb_item_from_menu :admin_pages_sidebar_menu

    before_action :set_contact_info_groups_breadcrumb_item

    def index
      enforce_permission_to :update, :organization, organization: current_organization
    end

    def new
      enforce_permission_to :update, :organization, organization: current_organization
      @form = form(Decidim::AdminExtended::ContactInfoGroupForm).instance
    end

    def create
      enforce_permission_to :update, :organization, organization: current_organization
      @form = form(Decidim::AdminExtended::ContactInfoGroupForm).from_params(params)

      Decidim::AdminExtended::CreateContactInfoGroup.call(@form) do
        on(:ok) do
          flash[:notice] = I18n.t(".contact_info_groups.create.success", scope: "decidim.admin_extended")
          redirect_to decidim_admin_extended.contact_info_positions_path
        end

        on(:invalid) do
          flash.now[:alert] = I18n.t(".contact_info_groups.create.errors", scope: "decidim.admin_extended")
          render :new
        end
      end
    end

    def edit
      enforce_permission_to :update, :organization, organization: current_organization
      @form = form(Decidim::AdminExtended::ContactInfoGroupForm).from_model(contact_info_group)
    end

    def update
      enforce_permission_to :update, :organization, organization: current_organization
      @form = form(Decidim::AdminExtended::ContactInfoGroupForm).from_params(params)

      Decidim::AdminExtended::UpdateContactInfoGroup.call(contact_info_group, @form) do
        on(:ok) do
          flash[:notice] = I18n.t(".contact_info_groups.update.success", scope: "decidim.admin_extended")
          redirect_to decidim_admin_extended.contact_info_positions_path
        end

        on(:invalid) do
          flash.now[:alert] = I18n.t(".contact_info_groups.update.errors", scope: "decidim.admin_extended")
          render :edit
        end
      end
    end

    def destroy
      enforce_permission_to :update, :organization, organization: current_organization
      contact_info_group.destroy!
      flash[:notice] = I18n.t(".contact_info_groups.destroy.success", scope: "decidim.admin_extended")
      redirect_to decidim_admin_extended.contact_info_positions_path
    end

    private

    def tab_menu_name = :admin_contact_info_positions_menu

    def contact_info_groups
      Decidim::AdminExtended::ContactInfoGroup.sorted_by_weight
    end

    def contact_info_group
      @contact_info_group ||= Decidim::AdminExtended::ContactInfoGroup.find_by(id: params[:id])
    end

    def set_contact_info_groups_breadcrumb_item
      controller_breadcrumb_items << {
        label: I18n.t("contact_info_groups.title", scope: "decidim.admin"),
        url: decidim_admin_extended.contact_info_groups_path,
        active: true
      }
    end
  end
end
