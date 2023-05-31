# frozen_string_literal: true

module Decidim::ConsultationMap
  class RemarksController < Decidim::ConsultationMap::ApplicationController
    include Decidim::FormFactory
    include Decidim::FilterResource
    include Decidim::Paginable
    include Decidim::Flaggable

    invisible_captcha on_spam: :spam_detected

    helper_method :remarks, :remark, :paginated_remarks, :all_locations,
                  :remarks_help_section, :remark_token, :created_remark

    before_action :verify_users_action_availability, only: [:new, :edit]

    def index
      enforce_permission_to :read, :remark
      @form = new_remark_form

      respond_to do |format|
        format.html
        format.js
      end
    end

    def show
      enforce_permission_to :read, :remark
      @remarks = remarks.where(id: params[:id])
      @remark = remarks.find_by(id: params[:id])
      # add premissions to see hidden modearate
      respond_to do |format|
        format.html { render :index }
        format.js
      end
    end

    def new
      enforce_permission_to :create, :remark

      @form = form(Decidim::ConsultationMap::RemarkForm)
              .from_model(Decidim::ConsultationMap::Remark.new(locations: params[:coords]))
              .with_context(current_component: current_component, current_user: current_user)

      respond_to do |format|
        format.js
      end
    end

    def create
      enforce_permission_to :create, :remark
      @form = form(Decidim::ConsultationMap::RemarkForm)
              .from_params(params)
              .with_context(current_component: current_component, current_user: current_user)

      Decidim::ConsultationMap::CreateRemark.call(@form, current_user) do
        on(:ok) do
          session[:remark_token] = Decidim::ConsultationMap::Remark.last.token

          respond_to do |format|
            format.js { render current_user ? :thank_you : :create }
            format.html { redirect_to remarks_path, notice: I18n.t("remarks.create.success", scope: "decidim.consultation_map") }
          end
        end

        on(:invalid) do
          respond_to do |format|
            format.js { render :new }
            format.html { render :new, alert: I18n.t("remarks.create.invalid", scope: "decidim.consultation_map") }
          end
        end
      end
    end

    # GET Action used for full edit
    def edit
      @remark = if current_user
                  Decidim::ConsultationMap::Remark.user_remarks(current_user.id).find_by(id: params[:id])
                elsif session[:remark_token].present?
                  Decidim::ConsultationMap::Remark.find_by(token: session[:remark_token])
                end

      if @remark
        @form = form(Decidim::ConsultationMap::RemarkForm).from_model(@remark)
                                                          .with_context(current_component: current_component, current_user: current_user)

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

    def second_step_update
      @remark = Decidim::ConsultationMap::Remark.find_by(token: session[:remark_token]) if !current_user && session[:remark_token].present?

      if @remark
        @form = form(Decidim::ConsultationMap::RemarkForm)
                .from_params(params.merge(body: @remark.body, category: @remark.category, signature: @remark.signature, images: @remark.images))
                .with_context(current_component: current_component, current_user: current_user)

        Decidim::ConsultationMap::SecondStepRemarkUpdate.call(@form, @remark) do
          on(:ok) do
            respond_to do |format|
              format.html { redirect_to remarks_path, notice: I18n.t("remarks.update.success", scope: "decidim.consultation_map") }
              format.js { render :thank_you }
            end
          end

          on(:invalid) do
            respond_to do |format|
              format.js { render :second_step_update_error }
            end
          end
        end
      else
        respond_to do |format|
          format.html { redirect_to remarks_path, alert: 'Coś poszło nie tak' }
          format.js { render js: "window.location.href='#{remarks_path}'" }
        end
      end
    end

    # PATCH Action for full update
    def update
      @remark = if current_user
                  Decidim::ConsultationMap::Remark.user_remarks(current_user.id).find_by(id: params[:id])
                elsif session[:remark_token].present?
                  Decidim::ConsultationMap::Remark.find_by(token: session[:remark_token])
                end
      if @remark
        @form = form(Decidim::ConsultationMap::RemarkForm)
                .from_params(params.merge(rodo: true)) # passing rodo for validation pass
                .with_context(current_component: current_component, current_user: current_user)

        Decidim::ConsultationMap::UpdateRemark.call(@form, @remark, current_user) do
          on(:ok) do
            respond_to do |format|
              format.html { redirect_to remarks_path, notice: I18n.t("remarks.update.success", scope: "decidim.consultation_map") }
              format.js { render :update }
            end
          end

          on(:invalid) do
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
      @remarks ||= search.results.with_attached_images
    end

    # def remark
    #   @remark ||= remarks.find(params[:remark_id])
    # end

    def new_remark_form
      form(Decidim::ConsultationMap::RemarkForm)
        .from_model(Decidim::ConsultationMap::Remark.new(locations: params[:coords]))
        .with_context(current_component: current_component, current_user: current_user)
    end

    def created_remark
      if current_user
        Decidim::ConsultationMap::Remark.user_remarks(current_user.id).last
      elsif session[:remark_token]
        Decidim::ConsultationMap::Remark.find_by(token: session[:remark_token])
      end
    end

    def remark_token
      @remark_token ||= session[:remark_token]
    end

    def all_locations
      @all_locations ||= remarks.map { |r| r.map_location }.to_json
    end

    def paginated_remarks
      @paginated_remarks ||= paginate(remarks)
    end

    def search_klass
      Decidim::ConsultationMap::RemarkSearch
    end

    def default_search_params
      {
        page: params[:page],
        per_page: 12
      }
    end

    def default_filter_params
      {
        search_text: "",
        decidim_category_id: ""
      }
    end

    def spam_detected
      flash[:alert] = 'Treści zostały zablokowane. Podejrzenie spamu.'
      redirect_to remarks_path
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
