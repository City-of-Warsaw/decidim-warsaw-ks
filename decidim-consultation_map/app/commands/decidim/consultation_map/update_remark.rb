# frozen_string_literal: true

module Decidim
  module ConsultationMap
    # This class holds logic to full update of Remarks
    # After initially added, Remark data can be edited by the author which is unregistered user:
    # - signature
    # - email
    # - district_id
    # - age
    # - gender
    # In both cases Boolean field 'edited' is marked as true
    class UpdateRemark < Rectify::Command
      # Initializes a UpdateRemark Command.
      #
      # form - The form from which to get the data.
      # current_user - The current instance of the remark to be updated.
      def initialize(form, remark, author)
        @form = form
        @remark = remark
        @current_organization = form.current_organization
        @component = form.component
        @author = author || unregistered_author
      end

      # Updates the remark if valid.
      #
      # Broadcasts :ok if successful, :invalid otherwise.
      def call
        return broadcast(:invalid) if @form.invalid?

        update_remark
        broadcast(:ok, @remark)
      end

      private

      def update_remark
        params = if @author.is_a?(Decidim::User)
                    remark_attributes
                  else
                    remark_attributes.merge(unregistered_user_attributes)
                  end

        @remark.update(params)
      end

      def remark_attributes
        {
          body: @form.body, 
          category: @form.category,  
          images: @form.images
        }
      end

      def unregistered_user_attributes
        { 
          signature: @form.signature,
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
