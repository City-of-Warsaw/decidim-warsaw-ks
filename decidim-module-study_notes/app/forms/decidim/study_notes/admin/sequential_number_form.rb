# frozen_string_literal: true

module Decidim::StudyNotes
  # This class holds a Form to update study note with sequential number
  class Admin::SequentialNumberForm < Decidim::Form
    mimic :study_note

    attribute :id_from, Integer
    attribute :id_to, Integer
    attribute :sequential_number, Integer
    attribute :force_override, Decidim::AttributeObject::TypeMap::Boolean, default: false

    { id_from: 1, id_to: 1, sequential_number: 0 }.each do |attr, min|
      validates attr, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: min }
    end

    validate :existing_sequential_number
    validate :unique_of_sequential_number

    def existing_sequential_number
      existing_ids = Decidim::StudyNotes::StudyNote.where(id: id_from..id_to, component: current_component)
                                                   .where.not(sequential_number: nil)
                                                   .pluck(:id)
      if existing_ids.any?
        errors.add(:id_from, "Numer ID Decidim: #{existing_ids.join(", ")} ma już nadany numer wewnętrzny")
      end
    end

    def unique_of_sequential_number
      if Decidim::StudyNotes::StudyNote.where(component: current_component)
                                       .where("sequential_number = ? AND id >= ? AND id <= ?", sequential_number, id_from, id_to)
                                       .exists?

        errors.add(:sequential_number, "Podana liczba znajduje się w zakresie liczb wskazanych, jako numer wewnętrzny")
      end
    end
  end
end
