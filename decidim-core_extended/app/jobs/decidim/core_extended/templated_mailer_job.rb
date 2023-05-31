# frozen_string_literal: true

module Decidim
  module CoreExtended
    # This job is used to queue all the mails that are using templates defined in admin panel.
    class TemplatedMailerJob < ApplicationJob
      include Decidim::EmailChecker

      queue_as :events

      # method takes parameters:
      # action_name - Symbol - to determine receivers and later MailTemplate
      # additional_data - Hash - holding all the data needed for mapping:
      #   - consultation - ParticipatoryProcess
      #   - step - ParticipatoryProcessStep
      #   - resource - ParticipatoryProcess, Meeting, Remark, etc
      #   - system elements: activation_link, password_reset_link
      def perform(action_name, additional_data = {})
        resource = additional_data[:resource]
        receivers = receivers(action_name, resource, additional_data)

        receivers.each do |receiver|
          if resource.is_a?(Decidim::ParticipatoryProcess)
            Decidim::ParticipatoryProcessesExtended::ProcessMailer.notify_about_consultation(action_name, resource, receiver).deliver_now

          elsif resource.is_a?(Decidim::Component)
            Decidim::ParticipatoryProcessesExtended::ProcessMailer.component_published(action_name, resource, receiver).deliver_now

          elsif resource.is_a?(Decidim::ExpertQuestions::Expert)
            Decidim::ParticipatoryProcessesExtended::ProcessMailer.expert_published(action_name, resource, receiver).deliver_now

          elsif resource.is_a?(Decidim::Comments::Comment)
            if resource.root_commentable.is_a? Decidim::Proposals::Proposal
              Decidim::ParticipatoryProcessesExtended::ProcessMailer.new_comment_to_proposal(action_name, resource.root_commentable, receiver).deliver_now
            elsif resource.root_commentable.is_a? Decidim::Remarks::Remark
              Decidim::ParticipatoryProcessesExtended::ProcessMailer.new_comment_to_remark(action_name, resource.root_commentable, receiver).deliver_now
            end

          elsif resource.is_a?(Decidim::ParticipatoryProcessStep)
            Decidim::ParticipatoryProcessesExtended::ProcessMailer.notify_about_step(action_name, resource, receiver).deliver_now

          elsif resource.is_a?(Decidim::StudyNotes::StudyNote)
            Decidim::ParticipatoryProcessesExtended::ProcessMailer.confirmation_about_study_note_user(action_name, resource, receiver).deliver_now

          elsif resource.is_a?(Decidim::ExpertQuestions::UserQuestion)
            # no followers mailer - only mail for author
          elsif resource.is_a?(Decidim::Meetings::Meeting)
            Decidim::ParticipatoryProcessesExtended::MeetingMailer.notify(action_name, resource, receiver).deliver_now

          elsif resource.is_a?(Decidim::Attachment)
            Decidim::CoreExtended::TemplatedMailer.notify(action_name, receiver, { attached_to: resource.attached_to }).deliver_now
          end
        end

      end

      def receivers(action_name, resource, additional_data = {})
        case action_name
        when 'resource_hidden' # usuniecie (schowanie) komentarza lub innego zasobou przez admina
          [additional_data[:author]]
        when 'component_published'
          process = resource.participatory_space
          process.find_possible_followers.where(email_on_notification: true) + process.email_follows

        when 'new_comment_to_proposal'
          proposal = resource.root_commentable
          proposal.followers.not_blocked.confirmed.where(email_on_notification: true) + proposal.email_follows

        when 'create_study_note_confirmation'
          user_email = Array.wrap(Decidim::User.new(email: resource.email))
          admin_email = Array.wrap(Decidim::User.new(email: resource.component.admin_email))
          user_email + admin_email

        when 'new_comment_to_remark'
          remark = resource.root_commentable
          process = remark.component.participatory_space
          process.find_possible_followers.where(email_on_notification: true) + process.email_follows

        when 'new_process_created_by_coordinator'
          Decidim::User.admins

        when 'new_process_published'
          # Resource is freshly published ParticipatoryProcess
          resource.find_published_process_followers
        when 'expert_published'
          # Resource is Expert
          resource.participatory_space.find_possible_followers.where(email_on_notification: true) + resource.participatory_space.email_follows

        when 'process_updated', 'report_published'
          # Resource is ParticipatoryProcess
          resource.find_possible_followers.where(email_on_notification: true) + resource.email_follows

       when 'meeting_updated'
          # Resource is ComponentResource with it's own followers: Meeting
          # Info for resource followers
          resource.followers.not_blocked.confirmed.where(email_on_notification: true)

        when 'meeting_in_two_days'
          meeting = additional_data[:meeting]
          consultation = additional_data[:consultation]
          # meeting.followers - zwraca tez obserwujacych konsultacje
          (meeting.followers.not_blocked.confirmed.where(email_on_notification: true) +
            consultation.find_possible_followers.where(email_on_notification: true) +
            consultation.email_follows).uniq

        when 'attachment_created'
          resource = additional_data[:resource]
          attached_to = resource.attached_to
          if attached_to.is_a?(Decidim::ParticipatoryProcess)
            consultation = attached_to
            consultation.find_possible_followers.where(email_on_notification: true) + consultation.email_follows
          elsif attached_to.is_a?(Decidim::Meetings::Meeting)
            attached_to.followers.not_blocked.confirmed.where(email_on_notification: true)
          elsif attached_to.is_a?(Decidim::ConsultationRequests::ConsultationRequest)
            # TODO: dodac obserwujacych niezalogowanych
            attached_to.followers
          else
            # i.e. attached_to.is_a?(Decidim::News::Information)
            []
          end

        when 'new_meeting', 'two_days_till_consultations_end'
          # Resource is ComponentResource: UserQuestion, Survey
          # Info for all Space followers
          consultation = additional_data[:consultation]
          consultation.find_possible_followers.where(email_on_notification: true) + consultation.email_follows

        when 'process_step_activation'
          # Resource is Decidim::ParticipatoryProcessStep
          consultation = additional_data[:consultation]
          consultation.find_possible_followers.where(email_on_notification: true)
        else
          resource.followers.not_blocked.confirmed.where(email_on_notification: true)
        end
      end
    end
  end
end
