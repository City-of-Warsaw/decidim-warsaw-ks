# frozen_string_literal: true

Decidim::Admin::Logs::Filterable.class_eval do
  private

  # ovewritten method
  # add sort by
  def extra_allowed_params
    [:per_page, :sort_by]
  end
end
