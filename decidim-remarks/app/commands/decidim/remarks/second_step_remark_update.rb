# frozen_string_literal: true

module Decidim
  module Remarks
    # This Command is used EXCLUSIVELY by Unregistered users, to save statistics data for the second step of adding new Remark
    # It uses update method, as data is additional to the required body part of the model.
    # This command is not used in any other moment.
    #
    # In this case Boolean field 'edited' has default value of false, as this Command is used only in one specific moment:
    # right after creation to gather statistical data
    class SecondStepRemarkUpdate < Decidim::Command
      include Decidim::CoreExtended::AuthorParamsBuilder
      include Decidim::CoreExtended::GenerateTokenHelper

      # Initializes a SecondStepRemarkUpdate Command.
      #
      # form - A form object with the params.
      # remark - A remark object with the params.
      # current_organization - A current organization object
      # component - A current component object
      # author - not registered user
      def initialize(form, remark)
        @form = form
        @remark = remark
        @current_organization = form.current_organization
        @component = form.component
        @author = unregistered_author
      end

      # Updates the remark if valid.
      #
      # Broadcasts :ok if successful, :invalid otherwise.
      def call
        return broadcast(:invalid) if @form.invalid?

        update_remark_stats
        broadcast(:ok, @remark)
      end

      private

      def update_remark_stats
        @remark.update(author_second_step_params)
      end
    end
  end
end
