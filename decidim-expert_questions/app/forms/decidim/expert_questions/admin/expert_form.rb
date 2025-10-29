# frozen_string_literal: true

module Decidim
  module ExpertQuestions
    module Admin
      # This class holds a Form to create/update translatable meetings from Decidim's admin panel.
      class ExpertForm < Decidim::Form
        mimic :expert

        attribute :full_name, String
        attribute :affiliation, String
        attribute :description, String
        attribute :avatar
        attribute :weight, Integer

        validates :full_name, :weight, presence: true
        validates :avatar, passthru: { to: Decidim::ExpertQuestions::Expert }
        validates :avatar, presence: true, unless: :persisted?
      end
    end
  end
end
