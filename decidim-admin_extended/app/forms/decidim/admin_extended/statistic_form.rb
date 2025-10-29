# frozen_string_literal: true

module Decidim
  module AdminExtended
    # A form object to update Statistic.
    class StatisticForm < Form
      attribute :name, String
      attribute :weight, Integer
      attribute :additional_statistic_number, Integer
      attribute :visibility, GraphQL::Types::Boolean

      mimic :statistic

      validates :name, presence: true
      validates :weight, presence: true, numericality: { only_integer: true }
      validates :additional_statistic_number, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }

      end
  end
end
