# frozen_string_literal: true

module Decidim
  module Remarks
    # This class holds logic for creating Remarks
    class CreateRemark < Decidim::Command
      include Decidim::CoreExtended::RegisteredUserHelper
      # Initializes a CreateUserQuestion Command.
      #
      # form - The form from which to get the data.
      # current_user - The current instance of the remark to be updated.
      def initialize(form, author)
        @form = form
        @current_organization = form.current_organization
        @component = form.component
        @author = author || unregistered_author
      end

      # Updates the remark if valid.
      #
      # Broadcasts :ok if successful, :invalid otherwise.
      def call
        return broadcast(:invalid) if @form.invalid?

        create_remark
        notify_followers_about_new_remark
        broadcast(:ok, @remark)
      end

      private

      def create_remark
        @remark = Decidim.traceability.create!(
          Decidim::Remarks::Remark,
          @author,
          remark_attributes,
          visibility: "public-only"
        )

        @remark.update(second_step_params) unless @author == unregistered_author
      end

      def remark_attributes
        {
          body: @form.body,
          author: @author,
          component: @component,
          signature: @form.signature,
          token: generate_token
        }.tap do |attr|
          attr[:files] = @form.files if @form.files.present?
        end
      end

      # Private method
      # returns special object that serves as Author for remarks created by unregistered users
      def unregistered_author
        @unregistered_author ||= Decidim::CoreExtended::UnregisteredAuthor.first
      end

      def generate_token
        @author.is_a?(Decidim::CoreExtended::UnregisteredAuthor) ? SecureRandom.hex(rand(59)) : nil
      end

      # use first remark of that component as resource
      # that remark is followed by users
      def notify_followers_about_new_remark
        system_remark = Decidim::Remarks::Remark.where(
          body: "system_generated_hidden_remark",
          component: @component
        ).order(:created_at).first

        return unless system_remark

        Decidim::CoreExtended::TemplatedMailerJob.perform_later('new_remark', { resource: system_remark, remark_body: @remark.body })
      end
    end
  end
end
