# frozen_string_literal: true

module Decidim
  module News
    module Admin
      # Controller that allows to manage Information in admin panel
      class InformationsController < Decidim::News::Admin::ApplicationController
        include Decidim::Admin::Officializations::Filterable

        helper Decidim::ApplicationHelper
        helper Decidim::SanitizeHelper

        register_permissions(::Decidim::News::Admin::ApplicationController,
                             ::Decidim::News::Admin::Permissions,
                             ::Decidim::Admin::Permissions)

        def permission_class_chain
          ::Decidim.permissions_registry.chain_for(::Decidim::News::Admin::ApplicationController)
        end

        def index
          enforce_permission_to :index, :information

          @informations = filtered_collection
        end

        def new
          enforce_permission_to :update, :information

          @form = form(Decidim::News::Admin::InformationForm).instance
        end

        def create
          enforce_permission_to :update, :information

          @form = form(Decidim::News::Admin::InformationForm).from_params(params)

          Decidim::News::Admin::CreateInformation.call(@form) do
            on(:ok) do
              flash[:notice] = I18n.t('informations.create.success', scope: 'decidim.admin')
              redirect_to informations_path
            end

            on(:invalid) do
              flash.now[:alert] = I18n.t('informations.create.error', scope: 'decidim.admin')
              render :new
            end
          end
        end

        def edit
          enforce_permission_to :update, :information

          @form = form(Decidim::News::Admin::InformationForm).from_model(information)
        end

        def update
          enforce_permission_to :update, :information

          @form = form(Decidim::News::Admin::InformationForm).from_params(params)

          Decidim::News::Admin::UpdateInformation.call(information, @form) do
            on(:ok) do
              flash[:notice] = I18n.t('informations.update.success', scope: 'decidim.admin')
              redirect_to informations_path
            end

            on(:invalid) do
              flash.now[:alert] = I18n.t('informations.update.error', scope: 'decidim.admin')
              render :edit
            end
          end
        end

        def publish
          enforce_permission_to :update, :information

          Decidim::News::Admin::PublishInformation.call(information) do
            on(:ok) do
              flash[:notice] = I18n.t('informations.publish.success', scope: 'decidim.admin')
              redirect_to informations_path
            end
          end
        end

        def unpublish
          enforce_permission_to :update, :information

          Decidim::News::Admin::UnpublishInformation.call(information) do
            on(:ok) do
              flash[:notice] = I18n.t('informations.unpublish.success', scope: 'decidim.admin')
              redirect_to informations_path
            end
          end
        end

        def destroy
          enforce_permission_to :update, :information

          Decidim::News::Admin::DestroyInformation.call(information) do
            on(:ok) do
              flash[:notice] = I18n.t('informations.destroy.success', scope: 'decidim.admin')
              redirect_to informations_path
            end
          end
        end

        private

        def information
          @information ||= collection.find_by(id: params[:id])
        end

        # admin can preview unpublished information in public view, from admin panel
        def collection
          @collection ||= Decidim::News::Information.where(decidim_organization_id: current_organization.id)
                                                    .sorted_by_weight
        end
      end
    end
  end
end
