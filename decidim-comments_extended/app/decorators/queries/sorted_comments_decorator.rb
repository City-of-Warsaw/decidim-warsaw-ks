# frozen_string_literal: true

Decidim::Comments::SortedComments.class_eval do
  private

  # Overwritten
  # Change sort by last updated
  def order_by_recent(scope)
    scope.order(updated_at: :desc)
  end
end