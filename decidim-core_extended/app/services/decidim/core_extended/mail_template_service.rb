# frozen_string_literal: true

module Decidim
  module CoreExtended
    # This service is used to handle all logic for MailTemplate fetching and returning with
    class MailTemplateService
      # action_name - is a name of a template to send
      # receiver - record of: User, UnregisteredAuthor or EmailFollow
      # passed_data - Hash with additionam params, can be:
      # - step
      # - expert
      # - reason_for_blocking
      # - activation_link
      # - password_reset_link
      def initialize(action_name, receiver, passed_data)
        @mail_template = Decidim::AdminExtended::MailTemplate.find_by system_name: action_name

        @params = passed_data
        @consultation = passed_data[:consultation]
        @resource = passed_data[:resource]

        @mail_receiver = Decidim::MailReceiver.new(receiver, @resource)

        @organization = @consultation&.organization.presence || @resource&.organization.presence || Decidim::Organization.first
        # @locale = @receiver&.locale.presence || 'pl'
        @locale = 'pl'
      end

      attr_reader :mail_template, :mail_receiver, :params

      def email
        mail_receiver.email
      end

      def active?
        mail_template.active?
      end

      def parse_body
        body = mail_template.body
        body = substitute_receiver_data_on(body)
        body = substitute_consultation_data_on(body) if @consultation
        body = substitute_step_data_on(body)
        body = substitute_resource_data_on(body) if @resource
        body = substitute_expert_data_on(body)
        body = substitute_reason_for_blocking_data_on(body)
        body = substitute_activation_link(body)
        body = substitute_password_reset_link(body)
        body = substitute_report_reasons(body)
        body = substitute_reported_content(body)
        body = substitute_resource_content(body)
        body = substitute_attached_to(body)

        body
      end
      alias_method :parsed_body, :parse_body

      def parse_subject
        subject = mail_template.subject
        subject = substitute_receiver_data_on(subject)
        subject = substitute_consultation_data_on(subject) if @consultation
        subject = substitute_step_data_on(subject)
        subject = substitute_resource_data_on(subject) if @resource
        subject = substitute_expert_data_on(subject)
        subject = substitute_attached_to(subject)

        subject
      end
      alias_method :parsed_subject, :parse_subject

      # def substitute_organization_data_on(text)
      #   text.gsub('%{user_name}', @receiver.name)
      # end

      def substitute_receiver_data_on(text)
        text.gsub('%{user_name}', @mail_receiver.name)
      end

      def substitute_resource_data_on(text)
        text.gsub('%{resource_title}', get_element_title(@resource))
            .gsub('%{resource_link}', get_element_url(@resource))
      end

      def substitute_consultation_data_on(text)
        text.gsub('%{consultation_title}', get_element_title(@consultation))
            .gsub('%{consultation_link}', get_element_url(@consultation))
      end

      def substitute_step_data_on(text)
        return text unless params[:step]

        text.gsub('%{step_name}', translated(params[:step].title))
      end

      def substitute_expert_data_on(text)
        return text unless params[:expert]

        text.gsub('%{expert_name}', params[:expert].position_and_name)
      end

      def substitute_reason_for_blocking_data_on(text)
        return text unless params[:reason_for_blocking]

        text.gsub('%{reason_for_blocking}', params[:reason_for_blocking])
      end

      def substitute_activation_link(text)
        return text unless params[:activation_link]

        text.gsub('%{activation_link}', "#{params[:activation_link]}")
      end

      def substitute_password_reset_link(text)
        return text unless params[:password_reset_link]

        text.gsub('%{password_reset_link}', "#{params[:password_reset_link]}")
      end

      def substitute_report_reasons(text)
        return text unless params[:report_reasons]

        report_reasons = params[:report_reasons].map do |reason|
          # I18n.t("decidim.admin.moderations.report.reasons.#{reason}").downcase
          I18n.t("decidim.shared.flag_modal.#{reason}").downcase
        end.join(", ")
        text.gsub('%{report_reasons}', "#{report_reasons}")
      end

      def substitute_reported_content(text)
        return text unless params[:reported_content]

        text.gsub('%{reported_content}', "#{params[:reported_content]}")
      end

      def substitute_resource_content(text)
        return text unless params[:resource_content]

        text.gsub('%{resource_content}', "#{params[:resource_content]}")
      end

      def substitute_attached_to(text)
        return text unless params[:attached_to]

        text.gsub('%{attached_to_title}', get_element_title(params[:attached_to]))
            .gsub('%{attached_to_link}', get_element_url(params[:attached_to]))
      end

      private

      def translated(obj)
        obj[@locale]
      end

      def get_element_title(resource)
        return 'Twoje pytanie' if resource.is_a?(Decidim::ExpertQuestions::UserQuestion)
        resource = resource.root_commentable if resource.is_a?(Decidim::Comments::Comment)

        if resource.respond_to?(:title)
          resource.title.class.name == 'Hash' ? resource.title[@locale] : resource.title
        elsif resource.respond_to?(:name)
          resource.name.class.name == 'Hash' ? resource.name[@locale] : resource.name
        else
          ''
        end
      end

      def get_element_url(resource)
        if resource.is_a?(Decidim::Component)
          "#{::Decidim::ResourceLocatorPresenter.new(resource.participatory_space).url.split('?').first}/f/#{resource.id}"
        elsif resource.is_a?(Decidim::Proposals::Proposal)
          "#{::Decidim::ResourceLocatorPresenter.new(resource.participatory_space).url.split('?').first}/f/#{resource.component.id}?proposal_id=#{resource.id}"
        elsif resource.is_a?(Decidim::Comments::Comment)
          ::Decidim::ResourceLocatorPresenter.new(resource.root_commentable).url
        else
          ::Decidim::ResourceLocatorPresenter.new(resource).url
        end
      end
    end
  end
end