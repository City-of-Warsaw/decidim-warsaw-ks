# frozen_string_literal: true

module Decidim
  module ParticipatoryProcessesExtended
    # This job is used to check end date of process steps and send emails with notification if its enabled
    class ActivateStepJob < ApplicationJob
      queue_as :events

      def perform
        participatory_processes = Decidim::ParticipatoryProcess.published

        Rails.logger.debug { "Aktywnych procesow #{participatory_processes.count}" }

        participatory_processes.each do |process|
          steps = Decidim::ParticipatoryProcessStep.unscoped
                                                   .where(decidim_participatory_process_id: process.id)
                                                   .where.not(end_date: nil)
                                                   .where("end_date <= ?", Time.current)
                                                   .order("end_date ASC", :position)

          active_step = process.steps.find_by(active: true)
          next unless active_step.present? && steps.pluck(:id).include?(active_step.id)

          Rails.logger.debug { "Krok do zmiany w procesie #{process.title}" }

          next_position = active_step.position + 1
          active_step.update(active: false)
          next_step = process.steps.find_by(position: next_position)
          next if next_step.blank?

          next_step.update(active: true)
          Rails.logger.debug { "Nastepny aktywowany, wysyłam maile #{process.title}" }

          Decidim::CoreExtended::TemplatedMailerJob.perform_later("process_step_activation", { resource: next_step })
        end
      end
    end
  end
end
