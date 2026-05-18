# frozen_string_literal: true

module Decidim
  module CoreExtended
    # This job is used to queue nearly all the mails that are using templates defined in admin panel.
    class TemplatedMailerJob < ApplicationJob
      include Decidim::EmailChecker

      queue_as :events

      # method takes parameters:
      # action_name - Symbol - to determine receivers and later MailTemplate
      # additional_data - Hash - holding all the data needed for mapping
      def perform(action_name, additional_data = {})
        Rails.logger.debug { "[TemplatedMailerJob] init perform" }

        resource = additional_data[:resource]
        receivers = receivers(action_name, resource, additional_data)
        return unless receivers

        receivers.each do |receiver|
          Rails.logger.debug { "[TemplatedMailerJob] iterate receivers: #{receivers.inspect}, resource: #{resource.inspect}" }

          email = receiver.respond_to?(:email) ? receiver.email : receiver[:email]

          Rails.logger.debug { "[TemplatedMailerJob] Receiver #{receiver.inspect} - Email: #{email} - Valid? #{valid_email?(email)}" }
          next unless valid_email?(email)

          Rails.logger.debug { "[TemplatedMailerJob] before case-when-switch" }

          case resource
          when Decidim::ParticipatoryProcess
            # action names:
            # - new_process_created_by_coordinator
            # - process_updated_by_admin
            # - new_process_published
            # - published_process_updated
            # - report_published
            # - notification_about_process_results

            Rails.logger.debug { "[TemplatedMailerJob] when ParticipatoryProcess before init ProcessMailer.notify_about_consultation" }
            Decidim::ParticipatoryProcessesExtended::ProcessMailer.notify_about_consultation(
              action_name, resource, receiver
            ).deliver_later

          when Decidim::ParticipatoryProcessStep
            # action names:
            # - process_step_activation
            # - process_step_changed

            Rails.logger.debug { "[TemplatedMailerJob] when ParticipatoryProcessStep before init ProcessMailer.notify_about_step" }
            Decidim::ParticipatoryProcessesExtended::ProcessMailer.notify_about_step(
              action_name, resource, receiver
            ).deliver_later

          when Decidim::Component
            # action names:
            # - component_published

            Rails.logger.debug { "[TemplatedMailerJob] when Component before init ProcessMailer.component_published" }
            Decidim::ParticipatoryProcessesExtended::ProcessMailer.component_published(
              action_name, resource, receiver
            ).deliver_later

          when Decidim::Attachment
            # action names:
            # - attachment_created

            Rails.logger.debug { "[TemplatedMailerJob] when Attachment before init TemplatedMailer.notify" }
            consultation = if resource.attached_to.is_a? Decidim::ParticipatoryProcess
                             resource.attached_to
                           else
                             resource.attached_to.participatory_space
                           end
            Decidim::CoreExtended::TemplatedMailer.notify(
              action_name, receiver, { attached_to: resource.attached_to, consultation: }
            ).deliver_later

          when Decidim::StudyNotes::StudyNote
            # action names:
            # - create_study_note_confirmation
            # - create_study_note_confirmation_to_submitter

            Rails.logger.debug { "[TemplatedMailerJob] when StudyNote before init ProcessMailer.confirmation_about_study_note_user" }
            Decidim::ParticipatoryProcessesExtended::ProcessMailer.confirmation_about_study_note_user(
              action_name, resource, receiver
            ).deliver_now

          when Decidim::GeneralPlanRequests::GeneralPlanRequest
            # action names:
            # - create_general_plan_request_confirmation_to_admin
            # - create_general_plan_request_confirmation_to_submitter

            Rails.logger.debug { "[TemplatedMailerJob] when GeneralPlanRequest before init ProcessMailer.confirmation_about_general_plan_request" }
            Decidim::ParticipatoryProcessesExtended::ProcessMailer.confirmation_about_general_plan_request(
              action_name, resource, receiver, additional_data[:anonymize_pdf]
            ).deliver_later

          when Decidim::Meetings::Meeting
            # action names:
            # - meeting_updated

            Rails.logger.debug { "[TemplatedMailerJob] when Meeting before init MeetingMailer.notify" }
            Decidim::ParticipatoryProcessesExtended::MeetingMailer.notify(
              action_name, resource, receiver
            ).deliver_later

          when Decidim::Comments::Comment
            # action names:
            # - new_comment_to_meeting
            # - new_comment_to_meeting_for_process_admin
            # - new_comment_to_custom_proposal
            # - new_comment_to_custom_proposal_for_process_admin
            # - new_comment_to_information
            # - new_comment_to_remark
            # - new_comment_to_map_remark
            # - new_comment_to_user_question
            # - new_reply_to_comment
            # - new_comment_or_remark_for_process_admin

            Rails.logger.debug { "[TemplatedMailerJob] when Comment before init TemplatedMailer.notify" }
            consultation = (resource.commentable.component.participatory_space if resource.commentable.respond_to?(:component))
            remark_or_its_comment_body = additional_data[:remark_or_its_comment_body]
            remark_or_its_comment_link = additional_data[:remark_or_its_comment_link]

            Decidim::CoreExtended::TemplatedMailer.notify(
              action_name,
              receiver,
              {
                comment: resource,
                resource: resource.commentable,
                consultation:,
                remark_or_its_comment_body:,
                remark_or_its_comment_link:
              }
            ).deliver_later

          when Decidim::CustomProposals::CustomProposal,
            Decidim::News::Information,
            Decidim::Remarks::Remark,
            Decidim::ExpertQuestions::UserQuestion,
            Decidim::ConsultationMap::Remark
            # action names:
            # - information_updated
            # - new_remark
            # - new_user_question
            # - new_map_remark
            # - new_comment_or_remark_for_process_admin
            # - new_map_remark_for_process_admin
            # - new_user_question_for_process_admin

            consultation = (resource.component.participatory_space if resource.respond_to?(:component))
            remark_body = additional_data[:remark_body]
            remark_or_its_comment_body = additional_data[:remark_or_its_comment_body]
            remark_or_its_comment_link = additional_data[:remark_or_its_comment_link]
            map_remark_body = additional_data[:map_remark_body]
            map_remark_link = additional_data[:map_remark_link]
            user_question_body = additional_data[:user_question_body]
            user_question_link = additional_data[:user_question_link]

            Rails.logger.debug { "[TemplatedMailerJob] when CustomProposal before init TemplatedMailer.notify" } if resource.is_a?(Decidim::CustomProposals::CustomProposal)
            Rails.logger.debug { "[TemplatedMailerJob] when Information before init TemplatedMailer.notify" } if resource.is_a?(Decidim::News::Information)
            Rails.logger.debug { "[TemplatedMailerJob] when Remark before init TemplatedMailer.notify" } if resource.is_a?(Decidim::Remarks::Remark)
            Rails.logger.debug { "[TemplatedMailerJob] when UserQuestion before init TemplatedMailer.notify" } if resource.is_a?(Decidim::ExpertQuestions::UserQuestion)
            Rails.logger.debug { "[TemplatedMailerJob] when Map Remark before init TemplatedMailer.notify" } if resource.is_a?(Decidim::ConsultationMap::Remark)

            Decidim::CoreExtended::TemplatedMailer.notify(
              action_name,
              receiver,
              {
                resource:,
                consultation:,
                remark_body:,
                remark_or_its_comment_body:,
                remark_or_its_comment_link:,
                map_remark_body:,
                map_remark_link:,
                user_question_body:,
                user_question_link:
              }
            ).deliver_later

          when Decidim::ExpertQuestions::ExpertAnswer
            # action names:
            # - experts_answer_to_user_question

            consultation = resource.component.participatory_space

            Rails.logger.debug { "[TemplatedMailerJob] when ExpertAnswer before init TemplatedMailer.notify" }
            Decidim::CoreExtended::TemplatedMailer.notify(
              action_name,
              receiver,
              {
                user_question: additional_data[:user_question],
                resource:, expert: additional_data[:expert],
                consultation:
              }
            ).deliver_later
          when Decidim::Forms::QuestionnairesUserData
            Rails.logger.debug { "[TemplatedMailerJob] when user reponse for questionnaire" }
            Decidim::CoreExtended::TemplatedMailer.notify(
              action_name, receiver, {
              questionnaires_user_data: resource,
              consultation: resource.questionnaire.questionnaire_for.component.participatory_space
            }
            ).deliver_later
          end

        rescue ActiveSupport::MessageEncryptor::InvalidMessage => e
          Rails.logger.warn("[TemplatedMailerJob] Skipped invalid encrypted message for receiver #{receiver&.id || "unknown"}: #{e.message}")
        rescue StandardError => e
          Rails.logger.error("[TemplatedMailerJob] Unexpected error for receiver #{receiver&.id || "unknown"}: #{e.class} - #{e.message}")
        rescue => e
          Rails.logger.error { "[TemplatedMailerJob] Mail sending failed for #{email}: #{e.message}" }
        end
      end

      def receivers(action_name, resource, additional_data = {})
        case action_name
          # THE PROCESS RECEIVERS
        when "new_process_created_by_coordinator",
          "process_updated_by_admin"
          ad_users = Decidim::User.admins.not_blocked.confirmed.where(email_on_notification: true)
          return [] if ad_users.blank?

          ad_users.to_a

        when "new_process_published"
          return [] unless resource

          resource.find_published_process_followers
        when "published_process_updated",
          "report_published",
          "notification_about_process_results",
          "two_days_till_consultations_end"
          return [] unless resource

          resource.find_possible_followers
        when "process_step_activation",
          "process_step_changed",
          "component_published"
          process = resource.participatory_space
          return [] unless process

          process.find_possible_followers

        when "new_comment_to_meeting_for_process_admin",
          "new_comment_to_custom_proposal_for_process_admin",
          "new_comment_or_remark_for_process_admin",
          "new_map_remark_for_process_admin",
          "new_user_question_for_process_admin"
          process = additional_data[:process]
          return [] unless process

          process.user_roles.map(&:user).select { |user| user.confirmed? && !user.blocked? }

        # CURRENTLY ATTACHMENT IS ONLY USED FOR PROCESS
        # THE RESOURCE.ATTACHED_TO'S RECEIVERS
        # WHEN resource.attached_to == Decidim::ParticipatoryProcess
        when "attachment_created"
          attached_to = resource.attached_to
          return [] unless attached_to.is_a?(Decidim::ParticipatoryProcess)

          attached_to.find_possible_followers

        # THE STUDY NOTE'S RECEIVERS - STUDY NOTE'S EMAIL AND EMAIL STORED IN STUDY NOTE'S COMPONENT
        when "create_study_note_confirmation"
          return [] unless resource

          [Decidim::User.new(email: resource.component.admin_email)]

          # THE STUDY NOTE REQUEST'S RECEIVER
          # STUDY NOTE REQUEST EMAIL STORED IN SINGLE STUDY NOTE ITEM
        when "create_study_note_confirmation_to_submitter"
          return [] unless resource
          return [] unless valid_email?(resource.email_confirmation_request)

          [Decidim::User.new(email: resource.email_confirmation_request)]
          # THE GENERAL PLAN REQUEST'S RECEIVER
          # GENERAL PLAN REQUEST EMAIL STORED IN GENERAL PLAN REQUEST'S COMPONENT
        when "create_general_plan_request_confirmation_to_admin"
          return [] unless resource

          [Decidim::User.new(email: resource.component.admin_email)]

          # THE GENERAL PLAN REQUEST'S RECEIVER
          # GENERAL PLAN REQUEST'S EMAIL
        when "create_general_plan_request_confirmation_to_submitter"
          return [] unless resource

          [Decidim::User.new(email: resource.email_confirmation_request)]

          # THE MEETING'S FOLLOWERS
          # WHEN RESOURCE == Decidim::Meetings::Meeting
        when "meeting_updated"
          return [] unless resource

          (resource.followers.not_blocked.confirmed.where(email_on_notification: true).to_a) + resource.email_follows.to_a

          # THE MEETING'S FOLLOWERS
          # WHEN RESOURCE == Decidim::Comments::Comment
        when "new_comment_to_meeting"
          meeting = additional_data[:meeting]
          return [] unless meeting

          (meeting.followers.not_blocked.confirmed.where(email_on_notification: true).to_a) + meeting.email_follows.to_a

          # THE CUSTOM PROPOSAL'S FOLLOWERS
          # WHEN RESOURCE == Decidim::Comments::Comment
        when "new_comment_to_custom_proposal"
          custom_proposal = additional_data[:custom_proposal]
          return [] unless custom_proposal

          (custom_proposal.followers.not_blocked.confirmed.where(email_on_notification: true).to_a) + custom_proposal.email_follows.to_a

          # THE INFORMATION'S FOLLOWERS
          # WHEN RESOURCE == Decidim::News::Information
        when "information_updated"
          return [] unless resource

          (resource.followers.not_blocked.confirmed.where(email_on_notification: true).to_a) + resource.email_follows.to_a

          # THE INFORMATION'S FOLLOWERS
          # WHEN RESOURCE == Decidim::Comments::Comment
        when "new_comment_to_information"
          information = additional_data[:information]
          return [] unless information

          (information.followers.not_blocked.confirmed.where(email_on_notification: true).to_a) + information.email_follows.to_a

          # THE REMARK'S FOLLOWERS
          # WHEN RESOURCE == Decidim::Remarks::Remark
        when "new_remark"
          return [] unless resource

          (resource.followers.not_blocked.confirmed.where(email_on_notification: true).to_a) + resource.email_follows.to_a

          # THE REMARK'S AUTHOR / THE USER QUESTION'S AUTHOR / THE MAP REMARK'S AUTHOR
          # WHEN RESOURCE == Decidim::Remarks::Remark /
          # WHEN RESOURCE == Decidim::ExpertQuestion::UserQuestion /
          # WHEN RESOURCE == Decidim::ConsultationMap::Remark
        when "new_comment_to_remark",
          "new_comment_to_user_question",
          "new_comment_to_map_remark"
          root_commentable = resource&.root_commentable
          return [] unless root_commentable&.author

          author = root_commentable.author
          return [] unless author.is_a?(Decidim::User) && author.confirmed? && author.email_on_notification?
          return [] if author.blocked?

          [author]

          # THE MAP REMARK'S FOLLOWERS
          # WHEN RESOURCE == Decidim::ConsultationMap::Remark
        when "new_map_remark"
          return [] unless resource

          (resource.followers.not_blocked.confirmed.where(email_on_notification: true).to_a) + resource.email_follows.to_a

          # THE USER QUESTION'S FOLLOWERS
          # WHEN RESOURCE == Decidim::ExpertQuestion::UserQuestion
        when "new_user_question"
          return [] unless resource

          (resource.followers.not_blocked.confirmed.where(email_on_notification: true).to_a) + resource.email_follows.to_a

          # AUTHOR OF THE USER QUESTION ANSWERED
        when "experts_answer_to_user_question"
          user_question = additional_data[:user_question]
          return [] unless user_question

          author = user_question.author
          return [] unless author.is_a?(Decidim::User) && author.confirmed? && author.email_on_notification?
          return [] if author.blocked?

          [author]

          # AUTHOR OF THE COMMENT REPLIED TO
        when "answer_questionnaire_confirmation_to_public_user"
          [resource]

        when "new_reply_to_comment"
          parent_of_reply = additional_data[:parent_of_reply]
          return [] unless parent_of_reply

          author = parent_of_reply.author
          return [] unless author.is_a?(Decidim::User) && author.confirmed? && author.email_on_notification?
          return [] if author.blocked?

          [author]
        else
          return [] unless resource

          (resource.followers.not_blocked.confirmed.where(email_on_notification: true).to_a) + resource.email_follows.to_a
        end
      end
    end
  end
end
