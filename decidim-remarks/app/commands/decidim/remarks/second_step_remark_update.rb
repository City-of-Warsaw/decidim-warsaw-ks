# frozen_string_literal: true

module Decidim
  module Remarks
    # This Command is used EXCLUSIVELY by Unregistered users, to save statistics data for the second step of adding new Remark
    # It uses update method, as data is additional to the required body part of the model.
    # This command is not used in any other moment.
    #
    # Attributes that are saved through this command:
    # - signature
    # - email
    # - district_id
    # - age
    # - gender
    #
    # In this case Boolean field 'edited' has default value of false, as this Command is used only in one specific moment:
    # right after creation to gather statistical data
    class SecondStepRemarkUpdate < Rectify::Command
      # Initializes a UpdateRemark Command.
      #
      # form - The form from which to get the data.
      # current_user - The current instance of the remark to be updated.
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
        @remark.update(remark_attributes)
      end

      def remark_attributes
        { 
          email: @form.email,
          district_id: @form.district_id,
          age: @form.age,
          gender: @form.gender
        }
      end

      def unregistered_author
        Decidim::CommentsExtended::UnregisteredAuthor.where(organization: @current_organization).first
      end
    end
  end
end
