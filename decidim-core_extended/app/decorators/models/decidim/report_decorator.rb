# frozen_string_literal: true

Decidim::Report.class_eval do
  # overwritten constant
  # reset that constant to add:
  # - other
  # - hidden_by_admin
  remove_const(:REASONS) if const_defined?(:REASONS)
  const_set(:REASONS, %w(spam offensive does_not_belong hidden_during_block parent_hidden other hidden_by_admin).freeze)

  # re-define reason validations to be safe
  _validators[:reason].clear
  _validate_callbacks.each do |callback|
    callback.filter.attributes.delete(:reason) if callback.filter.is_a?(ActiveModel::Validations::InclusionValidator)
  end
  validates :reason, inclusion: { in: Decidim::Report::REASONS }
end
