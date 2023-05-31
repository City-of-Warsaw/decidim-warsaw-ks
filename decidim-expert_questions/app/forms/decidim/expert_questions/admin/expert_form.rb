# frozen_string_literal: true

module Decidim
  module ExpertQuestions
    module Admin
      # This class holds a Form to create/update translatable meetings from Decidim's admin panel.
      class ExpertForm < Decidim::Form
        include Decidim::HasUploadValidations

        mimic :expert

        attribute :position, String
        attribute :affiliation, String
        attribute :description, String
        attribute :avatar, String
        attribute :remove_avatar
        attribute :decidim_user_id, Integer
        # attribute :decidim_component_id, Integer
        # attribute :published_at, Decidim::Attributes::TimeWithZone
        attribute :weight, Integer, default: 0

        validates :weight, numericality: { greater_than_or_equal_to: 0 }
        validates :current_component, presence: true
        validates :current_user, presence: true
        validates :decidim_user_id, presence: true
        validates :avatar, passthru: {
          to: Decidim::ExpertQuestions::Expert,
          with: {
            component: lambda do |form|
              Decidim::Component.new(participatory_space: form.current_component.participatory_space)
            end
          }
        }

        validate :user_is_expert
        validate :user_has_to_exist
        validate :expert_is_not_already_added, on: :create
        validate :elements_are_from_proper_organization
        validate :component_is_expert_questions

        alias component current_component

        def elements_are_from_proper_organization
          return unless user
          return unless component

          errors.add(:current_component, 'musi należeć do organizacji') unless user.organization == component.organization
        end

        def expert_is_not_already_added
          return unless user
          return unless component

          errors.add(:decidim_user_id, 'juz został dodany') if component_experts_ids.include?(user.id)
        end

        def user_is_expert
          return unless user

          errors.add(:decidim_user_id, 'musi mieć uprawnienia Eksperta z AD') unless user.ad_expert?
        end

        def user_has_to_exist
          errors.add(:decidim_user_id, 'musi mieć uprawnienia Eksperta z AD') unless user
        end

        def component_is_expert_questions
          return unless component

          errors.add(:current_component, 'nie mozna przypisać eksperta do tego komponentu') unless component&.manifest_name == 'expert_questions'
        end

        def user
          @user ||= Decidim::User.find_by(id: decidim_user_id)
        end

        def component_experts
          Decidim::ExpertQuestions::Expert.where(decidim_component_id: component.id)
        end

        def component_experts_ids
          @experts_ids ||= component_experts.map(&:decidim_user_id)
        end

        def users_select
          Decidim::User.where('ad_role LIKE ?', '%ekspert').where.not(id: component_experts_ids).map do |user|
            [
              user.name,
              user.id
            ]
          end
        end
      end
    end
  end
end
