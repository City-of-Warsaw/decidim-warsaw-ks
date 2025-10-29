# frozen_string_literal: true

module Decidim
  module ExpertQuestions
    module Admin
      # This class holds a Form to create/update translatable meetings from Decidim's admin panel.
      class UpdateExpert < Decidim::Command
        # Initializes a UpdateExpert Command.
        #
        # form - The form from which to get the data.
        # current_user - The current instance of the expert to be updated.
        def initialize(form, expert)
          super()
          @form = form
          @expert = expert
          @current_user = form.current_user
        end

        # Updates the expert if valid.
        #
        # Broadcasts :ok if successful, :invalid otherwise.
        def call
          return broadcast(:invalid) if @form.invalid?

          build_temp_expert
          @form.valid? && temp_expert.valid?
          update_expert
          broadcast(:ok)
        end

        private

        def build_temp_expert
          @temp_expert ||= Decidim::ExpertQuestions::Expert.new(
            component: @form.current_component,
            avatar: @form.avatar
          )
        end
        alias_method :temp_expert, :build_temp_expert

        def update_expert
          Decidim.traceability.update!(
            @expert,
            @current_user,
            expert_attributes,
            log_info
          )
        end

        def expert_attributes
          {
            full_name: @form.full_name,
            affiliation: @form.affiliation,
            description: @form.description,
            weight: @form.weight,
          }.tap do |attrs|
            attrs[:avatar] = @form.avatar if @form.avatar.present?
          end
        end

        def log_info
          {
            resource: {
              title: @expert.full_name
            },
            participatory_space: {
              title: @form.current_component.participatory_space.title
            }
          }
        end
      end
    end
  end
end
