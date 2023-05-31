require_dependency "decidim/admin_extended/application_controller"

module Decidim::AdminExtended
  class DepartmentsController < ApplicationController
    layout "decidim/admin/settings"

    def index
      enforce_permission_to :update, :organization, organization: current_organization

      @items = Decidim::AdminExtended::Department.all
    end

    def new
      enforce_permission_to :update, :organization, organization: current_organization
      @form = form(Decidim::AdminExtended::DepartmentForm).instance
    end

    def create
      enforce_permission_to :update, :organization, organization: current_organization
      @form = form(Decidim::AdminExtended::DepartmentForm).from_params(params)

      Decidim::AdminExtended::CreateDepartment.call(@form, current_user) do
        on(:ok) do
          flash[:notice] = I18n.t("departments.create.success", scope: "decidim.admin_extended")
          redirect_to decidim_admin_extended.departments_path
        end

        on(:invalid) do
          flash.now[:alert] = I18n.t("departments.create.error", scope: "decidim.admin_extended")
          render :new
        end
      end
    end

    def edit
      enforce_permission_to :update, :organization, organization: current_organization
      @form = form(Decidim::AdminExtended::DepartmentForm).from_model(department)
    end

    def update
      enforce_permission_to :update, :organization, organization: current_organization
      @form = form(Decidim::AdminExtended::DepartmentForm).from_params(params)

      Decidim::AdminExtended::UpdateDepartment.call(department, @form, current_user) do
        on(:ok) do
          flash[:notice] = I18n.t("departments.update.success", scope: "decidim.admin_extended")
          redirect_to decidim_admin_extended.departments_path
        end

        on(:invalid) do
          flash.now[:alert] = I18n.t("departments.update.error", scope: "decidim.admin_extended")
          render :edit
        end
      end
    end

    def destroy
      enforce_permission_to :update, :organization, organization: current_organization

      Decidim::AdminExtended::DestroyDepartment.call(department, current_user) do
        on(:ok) do
          flash[:notice] = I18n.t("departments.destroy.success", scope: "decidim.admin_extended")
          redirect_to departments_path
        end
        on(:has_spaces) do
          flash[:alert] = I18n.t("departments.destroy.has_spaces", scope: "decidim.admin_extended")
          redirect_to departments_path
        end
      end
    end

    private

    def department
      Decidim::AdminExtended::Department.find(params[:id])
    end
  end
end
