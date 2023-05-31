# frozen_string_literal: true

module Decidim
  module ExpertQuestions
    module Admin
      # This class holds a Form to create/update translatable meetings from Decidim's admin panel.
      class UpdateExpert < Rectify::Command
        # Initializes a UpdateExpert Command.
        #
        # form - The form from which to get the data.
        # current_user - The current instance of the expert to be updated.
        def initialize(form, expert)
          @form = form
          @expert = expert
          @current_user = form.current_user
          @form.avatar = @expert.avatar if @form.avatar.blank?
        end

        # Updates the expert if valid.
        #
        # Broadcasts :ok if successful, :invalid otherwise.
        def call
          return broadcast(:invalid) if @form.invalid?

          test_update_expert

          if @expert.valid?
            update_expert
            broadcast(:ok)
          else
            @form.errors.add :avatar, @expert.errors[:avatar] if @expert.errors.has_key? :avatar
            broadcast(:invalid)
          end
        end

        private

        def test_update_expert
          @expert.position = @form.position
          @expert.affiliation = @form.affiliation
          @expert.description = @form.description
          @expert.avatar = @form.avatar
          @expert.weight = @form.weight
          @expert.remove_avatar = @form.remove_avatar
        end

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
            position: @form.position,
            affiliation: @form.affiliation,
            description: @form.description,
            avatar: @form.avatar,
            # decidim_user_id: @form.decidim_user_id,
            weight: @form.weight,
            remove_avatar: @form.remove_avatar
            # component: @form.current_component
          }
        end

        def log_info
          {
            resource: {
              title: @expert.user.name
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
