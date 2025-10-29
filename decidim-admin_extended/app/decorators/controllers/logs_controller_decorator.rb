# frozen_string_literal: true

Decidim::Admin::LogsController.class_eval do
  helper_method :sort_by_select

  private

  # overwritten method
  # add sorting
  def logs
    @logs ||= begin
      scope = filtered_collection
      case params[:sort_by]
      when "created_at_asc"
        scope.order(created_at: :asc)
      else
        scope.order(created_at: :desc)
      end
    end
  end

  def sort_by_select
    [
      [t("decidim.admin.logs.filters.newest_first"), "created_at_desc"],
      [t("decidim.admin.logs.filters.oldest_first"), "created_at_asc"]
    ]
  end
end
