# frozen_string_literal: true

module Decidim::Remarks
  class RemarksController < Decidim::Remarks::ApplicationController
    include Decidim::FormFactory
    include Decidim::FilterResource
    include Decidim::Paginable
    include Decidim::Flaggable

    helper_method :remarks, :remark, :paginated_remarks, :remark_token,
                  :new_remark_form, :created_remark, :remarks_help_section

    before_action :verify_users_action_availability, only: [:new, :edit]

    def index
      enforce_permission_to :read, :remark

      @form = new_remark_form
    end

    def show
      enforce_permission_to :read, :remark
      @remarks = remarks.where(id: params[:id])
      @form = new_remark_form
      # add premissions to see hidden modearate
      render :index
    end

    def create
      enforce_permission_to :create, :remark
      @form = form(Decidim::Remarks::RemarkForm).from_params(params)

      Decidim::Remarks::CreateRemark.call(@form, current_user) do
        on(:ok) do |remark|
          session[:remark_token] = remark.token

          respond_to do |format|
            format.js { render current_user ? :thank_you : :create }
            format.html { redirect_to remarks_path, notice: I18n.t("remarks.create.success", scope: "decidim.remarks") }
          end
        end

        on(:invalid) do
          respond_to do |format|
            format.js { render :create_error }
            format.html { render :index, alert: I18n.t("remarks.create.invalid", scope: "decidim.remarks") }
          end
        end
      end
    end

    # GET Action used for full edit
    def edit
      @remark = if current_user
                  Decidim::Remarks::Remark.user_remarks(current_user.id).find_by(id: params[:id])
                elsif session[:remark_token].present?
                  Decidim::Remarks::Remark.find_by(token: session[:remark_token])
                end

      if @remark
        @form = form(Decidim::Remarks::RemarkForm).from_model(@remark)

        respond_to do |format|
          format.html
          format.js
        end
      else
        respond_to do |format|
          format.html { redirect_to remarks_path, alert: 'Cos poszło nie tak' }
          format.js { render js: "window.location.href='#{remarks_path}'" }
        end
      end
    end

    # PATCH Action for updating statistic data,
    # when unregistered user is on second step of Remark form
    def second_step_update
      @remark = Decidim::Remarks::Remark.find_by(token: session[:remark_token]) if !current_user && session[:remark_token].present?

      if @remark
        @form = form(Decidim::Remarks::RemarkForm)
                  .from_params(params.merge(body: @remark.body)) # passing body for validation pass

        Decidim::Remarks::SecondStepRemarkUpdate.call(@form, @remark) do
          on(:ok) do
            # flash[:notice] = I18n.t("remarks.update.success", scope: "decidim.remarks")
            respond_to do |format|
              format.html { redirect_to remarks_path, notice: I18n.t("remarks.update.success", scope: "decidim.remarks") }
              format.js { render :thank_you }
            end
          end

          on(:invalid) do
            # flash.now[:alert] = I18n.t("remarks.create.invalid", scope: "decidim.remarks")
            respond_to do |format|
              format.js { render :second_step_update_error }
            end
          end
        end
      else
        respond_to do |format|
          format.html { redirect_to remarks_path, alert: 'Cos poszło nie tak' }
          format.js { render js: "window.location.href='#{remarks_path}'" }
        end
      end
    end

    # PATCH Action for full update
    def update
      @remark = if current_user
                  Decidim::Remarks::Remark.user_remarks(current_user.id).find_by(id: params[:id])
                elsif session[:remark_token].present?
                  Decidim::Remarks::Remark.find_by(token: session[:remark_token])
                end
      if @remark
        @form = form(Decidim::Remarks::RemarkForm)
                  .from_params(params.merge(rodo: true)) # passing rodo for validation pass

        Decidim::Remarks::UpdateRemark.call(@form, @remark, current_user) do
          on(:ok) do
            # flash[:notice] = I18n.t("remarks.update.success", scope: "decidim.remarks")
            respond_to do |format|
              format.html { redirect_to remarks_path, notice: I18n.t("remarks.update.success", scope: "decidim.remarks") }
              format.js { render :update }
            end
          end

          on(:invalid) do
            # flash.now[:alert] = I18n.t("remarks.create.invalid", scope: "decidim.remarks")
            respond_to do |format|
              format.js { render :error }
            end
          end
        end
      else
        respond_to do |format|
          format.html { redirect_to remarks_path, alert: 'Cos poszło nie tak' }
          format.js { render js: "window.location.href='#{remarks_path}'" }
        end
      end
    end

    private

    def remarks
      # @remarks ||= Decidim::Remarks::UserQuestion.where(component: current_component).page(params[:page]).per(15)
      @remarks ||= search.results.latest_first
    end

    def paginated_remarks
      @paginated_remarks ||= paginate(remarks)
    end

    def new_remark_form
      form(Decidim::Remarks::RemarkForm).from_model(Remark.new)
    end

    # Private method that looks for freshly created remark to pass into create.js view
    def created_remark
      if current_user
        Decidim::Remarks::Remark.user_remarks(current_user.id).last
      elsif session[:remark_token]
        Decidim::Remarks::Remark.find_by(token: session[:remark_token])
      end
    end

    # Private method only used on views as helper method
    #
    # Method cannot be used in actions, as value of session[:remark_token] can be changed during one request
    def remark_token
      @remark_token ||= session[:remark_token]
    end

    def search_klass
      Decidim::Remarks::RemarkSearch
    end

    # overwritten default per page size to 12
    def per_page
      if OPTIONS.include?(params[:per_page])
        params[:per_page]
      elsif params[:per_page]
        sorted = OPTIONS.sort
        params[:per_page].to_i.clamp(sorted.first, sorted.last)
      else
        12
      end
    end

    def default_filter_params
      {
        search_text: ""
      }
    end

    def remarks_help_section
      current_component.settings[:help_section]
    end

    def verify_users_action_availability
      if current_component.users_action_disallowed? && !(current_user && current_user.has_ad_role?)
        redirect_to remarks_path, alert: current_component.end_date_message
      end
    end
  end
end
