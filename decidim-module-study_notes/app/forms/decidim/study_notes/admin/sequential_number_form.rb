# frozen_string_literal: true

module Decidim::StudyNotes
  # This class holds a Form to create sequntial numbers for study note items.
  class Admin::SequentialNumberForm < Decidim::Form
    mimic :sequential_number

    attribute :sequential_number, Integer
    validates :sequential_number, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  end
end
