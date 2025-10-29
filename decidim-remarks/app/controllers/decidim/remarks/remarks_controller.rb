# frozen_string_literal: true

module Decidim::Remarks
  class RemarksController < Decidim::Remarks::ApplicationController
    include Decidim::FormFactory
    include Decidim::FilterResource
    include Decidim::Paginable
    include Decidim::Flaggable
    include Decidim::CoreExtended::CommentTokenCookie

    before_action :authenticate_user!, only: [:vote]
    helper_method :remarks,
                  :remark,
                  :paginated_remarks,
                  :remark_token,
                  :new_remark_form,
                  :created_remark,
                  :first_followable_remark,
                  :user_allowed_to_add_remark?

    def index
      enforce_permission_to :read, :remark

      @form = new_remark_form
    end

    def show
      enforce_permission_to :read, :remark

      @remark = if current_user
                  # Try to find the remark within the current user's remarks
                  Decidim::Remarks::Remark.user_remarks(current_user.id).find_by(id: params[:id]) ||
                    # Fallback to finding the remark within all remarks
                    remarks.find_by(id: params[:id])
                elsif session[:remark_token].present?
                  # Find the remark using the session token
                  remarks.find_by(token: session[:remark_token])
                elsif params[:id]
                  # Find the remark within all remarks if an ID is provided
                  remarks.find(params[:id])
                end

      raise ActionController::RoutingError, "Not Found" unless @remark

      @remarks = remarks.where(id: params[:id])
      @form = new_remark_form
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
          format.html { redirect_to remarks_path, alert: "Cos poszło nie tak" }
          format.js { render js: "window.location.href='#{remarks_path}'" }
        end
      end
    end

    def vote
      raise ActionController::RoutingError, "Not Found" unless remark

      enforce_permission_to(:vote, :remark, remark:)

      Decidim::Remarks::VoteRemark.call(remark, current_user, weight: params[:weight].to_i) do
        on(:ok) do
          respond_to do |format|
            format.js { render :create_vote }
          end
        end
        on(:invalid) do
          respond_to do |format|
            format.js { render :error_vote }
          end
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
          format.html { redirect_to remarks_path, alert: "Cos poszło nie tak" }
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
        @form = form(Decidim::Remarks::RemarkForm).from_params(params)
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
          format.html { redirect_to remarks_path, alert: "Cos poszło nie tak" }
          format.js { render js: "window.location.href='#{remarks_path}'" }
        end
      end
    end

    private

    def remarks
      @remarks ||= filtered_remarks_list
    end

    def remark
      @remark ||= remarks.find(params[:id])
    end

    def filtered_remarks_list
      query = Decidim::Remarks::Remark.where(component: current_component)
                                      .without_system_hidden
                                      .latest_first

      return query if filtered_params.nil?

      search_text = filtered_params[:search_text]
      query.where("decidim_remarks_remarks.body ILIKE :text", text: "%#{search_text}%")
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

    def filtered_params
      return nil unless params[:filter]

      params.require(:filter).permit(:search_text)
    end

    def default_filter_params
      {
        search_text: ""
      }
    end

    # Returns the first remark in the database that belongs to current component
    # Thanks to the `create_system_followable_remark` method in:
    # `decidim-admin_extended/app/decorators/commands/publish_component_decorator.rb`,
    # there will always be at least one remark available for users to follow.
    def first_followable_remark
      return nil unless current_component&.published?

      @first_followable_remark ||= Decidim::Remarks::Remark.where(body: "system_generated_hidden_remark", component: current_component)
                                                           .order(:created_at)
                                                           .first
    end

    # remark's component settings be set in admin panel, to disallow to comment:
    # - if time set in the remark's component settings of the users_action_end_date field has passed
    # - participatory_space setting field: users_action_allowed_for_unregister_users
    def user_allowed_to_add_remark?(user)
      # scenario when component is closed
      return false if current_component.users_action_end_date&.past?
      # scenario when registered user is present
      return true if user.present?

      # scenario when unregistered author is present
      current_component.participatory_space.users_action_allowed_for_unregister_users?
    end
  end
end
