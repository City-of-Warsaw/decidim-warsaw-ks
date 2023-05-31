# frozen_string_literal: true

Decidim::Admin::LogsController.class_eval do

  def index
    enforce_permission_to :read, :admin_log
    @form = form(Decidim::AdminExtended::LogSearchForm).from_params(params)
    @logs = @form.find_logs.page(params[:page]).per(per_page)
  end

  private

  def per_page
    20
  end
end