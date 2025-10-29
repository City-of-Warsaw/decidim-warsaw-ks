# frozen_string_literal: true

module Decidim
  module CoreExtended
    # This service is used to handle all logic for MailTemplate fetching and returning with
    class MailTemplateService
      include Rails.application.routes.mounted_helpers

      def initialize(action_name, receiver, passed_data)
        @mail_template = Decidim::AdminExtended::MailTemplate.find_by system_name: action_name

        @params = passed_data
        @consultation = passed_data[:consultation]
        @resource = passed_data[:resource]
        @receiver = receiver
        @mail_receiver = Decidim::MailReceiver.new(receiver, @resource)

        @organization = @consultation&.organization.presence || @resource&.organization.presence || Decidim::Organization.first
        @locale = "pl"
      end

      attr_reader :mail_template, :mail_receiver, :params, :receiver

      def email
        mail_receiver.email
      end

      def active?
        mail_template.active?
      end

      def footer
        return nil if @mail_template.footer.blank?

        footer_string = @mail_template.footer
        footer_string = footer_string.gsub("%{notifications_settings_link}", decidim.notifications_settings_url(host: @organization.host))
        footer_string = footer_string.gsub("%{unsubscribe_link}", unsubscribe_link) if unsubscribe_link
        footer_string
      end

      def unsubscribe_link
        return unless @resource

        encrypted_token = Decidim::NewsletterEncryptor.sent_at_encrypted(receiver.id, receiver.class.to_s, "#{@resource.class.to_s}-#{@resource.id.to_s}")
        decidim.unsubscribe_newsletters_url(host: @organization.host, u: encrypted_token)
      end

      def parse_body
        body = mail_template.body
        body = body.gsub("%{notifications_settings_link}", decidim.notifications_settings_url(host: @organization.host))
        body = substitute_receiver_data_on(body)
        body = substitute_consultation_data_on(body) if @consultation
        body = substitute_step_data_on(body)
        body = substitute_resource_data_on(body) if @resource
        body = substitute_reason_for_blocking_data_on(body)
        body = substitute_activation_link(body)
        body = substitute_password_reset_link(body)
        body = substitute_report_reasons(body)
        body = substitute_reported_content(body)
        body = substitute_remark_body(body)
        body = manage_moderations_link(body) if @consultation
        body = substitute_resource_content(body)
        body = substitute_comment_on(body)
        body = substitute_attached_to(body)
        body = substitute_info_articles_link(body)
        body = substitute_substitute_consultation_report_description(body)
        body = substitute_consultation_first_result_body(body)
        body = substitute_questionnaires_user_data_body(body)
        body = substitute_study_note_zip_body(body)
        substitute_experts_answer_to_user_question(body)
      end

      alias parsed_body parse_body

      # used helpers for topic:
      # - user_name
      # - consultation_title
      # - consultation_link
      # - step_name
      # - resource_title
      # - resource_link
      # - attached_to_title
      # - attached_to_link
      # if there would be substitute for subject, it's helper MUST be added to:
      # decidim-admin_extended/app/forms/decidim/admin_extended/mail_template_form.rb
      # used_helpers_for_topic method
      def parse_subject
        subject = mail_template.subject
        subject = substitute_receiver_data_on(subject)
        subject = substitute_consultation_data_on(subject) if @consultation
        subject = substitute_step_data_on(subject)
        subject = substitute_resource_data_on(subject) if @resource
        substitute_attached_to(subject)
      end

      alias parsed_subject parse_subject

      def substitute_receiver_data_on(text)
        text.gsub("%{user_name}", @mail_receiver.name)
      end

      def substitute_resource_data_on(text)
        text.gsub("%{resource_title}", get_element_title(@resource))
            .gsub("%{resource_link}", get_element_url(@resource))
      end

      def substitute_comment_on(text)
        return text unless params[:comment]

        text.gsub("%{comment_body}", params[:comment].body["pl"])
            .gsub("%{commentable_title}", get_element_title(@resource))
            .gsub("%{commentable_link}", ::Decidim::ResourceLocatorPresenter.new(params[:comment].root_commentable).url)
      end

      def substitute_consultation_data_on(text)
        text.gsub("%{consultation_title}", get_element_title(@consultation))
            .gsub("%{consultation_link}", get_element_url(@consultation))
      end
      def substitute_remark_body(text)
        return text unless params[:remark_body]

        text.gsub('%{remark_body}', params[:remark_body])
      end

      def substitute_step_data_on(text)
        return text unless params[:step]

        text.gsub("%{step_name}", translated(params[:step].title))
      end

      def substitute_reason_for_blocking_data_on(text)
        return text unless params[:reason_for_blocking]

        text.gsub("%{reason_for_blocking}", params[:reason_for_blocking])
      end

      def substitute_activation_link(text)
        return text unless params[:activation_link]

        text.gsub("%{activation_link}", "#{params[:activation_link]}")
      end

      def substitute_password_reset_link(text)
        return text unless params[:password_reset_link]

        text.gsub("%{password_reset_link}", "#{params[:password_reset_link]}")
      end

      def substitute_report_reasons(text)
        return text unless params[:report_reasons]

        report_reasons = params[:report_reasons].map do |reason|
          # I18n.t("decidim.admin.moderations.report.reasons.#{reason}").downcase
          I18n.t("decidim.shared.flag_modal.#{reason}").downcase
        end.join(", ")
        text.gsub("%{report_reasons}", "#{report_reasons}")
      end

      def substitute_reported_content(text)
        return text unless params[:reported_content]

        text.gsub("%{reported_content}", params[:reported_content].gsub("\n", "<br>"))
      end

      def manage_moderations_link(text)
        text.gsub("%{manage_moderations_link}", Decidim::EngineRouter.admin_proxy(@consultation).moderations_url(host: @organization.host))
      end

      def substitute_resource_content(text)
        return text unless params[:resource_content]

        text.gsub("%{resource_content}", "#{params[:resource_content]}")
      end

      def substitute_attached_to(text)
        return text unless params[:attached_to]

        text.gsub("%{attached_to_title}", get_element_title(params[:attached_to]))
            .gsub("%{attached_to_link}", get_element_url(params[:attached_to]))
      end

      def substitute_info_articles_link(text)
        return text unless params[:info_articles_link]

        text.gsub("%{info_articles_link}", params[:info_articles_link])
      end

      def substitute_experts_answer_to_user_question(text)
        return text unless params[:expert]
        return text unless params[:user_question]

        text.gsub("%{expert_name}", params[:expert].full_name)
            .gsub("%{user_question_body}", params[:user_question].body)
      end

      def substitute_substitute_consultation_report_description(text)
        return text unless params[:report_description]

        text.gsub("%{report_description}", params[:report_description])
      end

      def substitute_consultation_first_result_body(text)
        return text unless params[:result_body]

        text.gsub("%{result_body}", params[:result_body])
      end

      def substitute_questionnaires_user_data_body(text)
        return text unless params[:questionnaires_user_data]

        questionnaire = params[:questionnaires_user_data].questionnaire

        user_token_with_link = "#{decidim.root_url(host: @organization.host)}processes/#{questionnaire.questionnaire_for.component.participatory_space.slug}/f/#{questionnaire.questionnaire_for.component.id}/response/#{params[:questionnaires_user_data].session_token}"
        # TODO FIX THIS LINK
        # user_token_with_link = Decidim::Surveys::Engine.routes.url_helpers.show_survey_responses_url(participatory_process_slug: questionnaire.questionnaire_for.component.participatory_space,
        #                                                                       component_id: questionnaire.questionnaire_for.component.id,
        #                                                                       uuid: params[:questionnaires_user_data].session_token)

        text.gsub("%{answer_questionnaire_public_user_link}", user_token_with_link)
      end

      def substitute_study_note_zip_body(text)
        return text unless params[:study_note_zip_link]

        text.gsub("%{study_note_zip_link}", params[:study_note_zip_link])
      end

      private

      def translated(obj)
        obj[@locale]
      end

      def get_element_title(resource)
        return "Twoje pytanie" if resource.is_a?(Decidim::ExpertQuestions::UserQuestion)

        resource = resource.root_commentable if resource.is_a?(Decidim::Comments::Comment)

        if resource.respond_to?(:title)
          resource.title.class.name == "Hash" ? resource.title[@locale] : resource.title
        elsif resource.respond_to?(:name)
          resource.name.class.name == "Hash" ? resource.name[@locale] : resource.name
        else
          ""
        end
      end

      def get_element_url(resource)
        case resource
        when Decidim::Component
          "#{::Decidim::ResourceLocatorPresenter.new(resource.participatory_space)
                                                .url.split("?")
                                                .first}/f/#{resource.id}"
        when Decidim::Comments::Comment
          ::Decidim::ResourceLocatorPresenter.new(resource.root_commentable).url
        when Decidim::Report
          ::Decidim::ResourceLocatorPresenter.new(resource.moderation.reportable.root_commentable).url
        when Decidim::Remarks::Remark,
          Decidim::ExpertQuestions::UserQuestion,
          Decidim::ExpertQuestions::ExpertAnswer,
          Decidim::ConsultationMap::Remark,
          Decidim::CustomProposals::CustomProposal

          "#{::Decidim::ResourceLocatorPresenter.new(resource.component.participatory_space)
                                                .url
                                                .split("?")
                                                .first}/f/#{resource.component.id}"
        else
          ::Decidim::ResourceLocatorPresenter.new(resource).url
        end
      end
    end
  end
end
