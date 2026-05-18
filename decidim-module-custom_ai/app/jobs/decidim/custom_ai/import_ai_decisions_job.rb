# frozen_string_literal: true

require "roo"

module Decidim
  module CustomAi
    class ImportAiDecisionsJob < ApplicationJob
      queue_as :events

      BATCH_SIZE = 500

      # must be the same as in Decidim::CustomAi::AnswersSerializer
      HEADER_MAP = {
        "ID uwagi" => "id",
        "Uzasadnienie" => "ai_decision_body",
        "Rozstrzygnięcie" => "ai_decision_status",
        "Status" => "status"
      }.freeze

      # down cased versions Decidim::CustomAi::AnswerEnums
      AI_DECISION_STATUS_MAP = {
        "istniejące zapisy strategii uwzględniają treść uwagi" => :included_in_strategy,
        "uwzględniliśmy" => :considered,
        "uwzględniliśmy częściowo" => :partially_considered,
        "nie uwzględniliśmy" => :not_considered,
        "nie dotyczy" => :not_applicable
      }.freeze

      # down cased versions Decidim::CustomAi::AnswerEnums
      STATUS_MAP = {
        "do ustalenia" => :pending,
        "wersja robocza" => :draft,
        "do weryfikacji" => :for_review,
        "zaakceptowane" => :accepted
      }.freeze

      def perform(user, attachment_id)
        @user = user
        @attachment = Decidim::Attachment.find(attachment_id)

        tempfile = Tempfile.new
        tempfile.binmode
        @attachment.file.blob.download { |chunk| tempfile.write(chunk) }
        tempfile.flush
        tempfile.rewind

        xlsx = Roo::Spreadsheet.open(tempfile.path, extension: :xlsx)
        sheet = xlsx.sheet(0)

        total_rows = sheet.last_row - 1 # to exclude headers
        updated_count = 0
        failed_rows = []

        headers = sheet.row(1).map(&:to_s)
        (2..sheet.last_row).each do |i|
          row = [headers, sheet.row(i)].transpose.to_h
          mapped = row.transform_keys { |h| HEADER_MAP[h] }.compact

          next if mapped["id"].blank?
          answer = Decidim::Forms::Answer.find_by(id: mapped["id"])
          unless answer
            failed_rows << i
            next
          end

          begin
            ai_decision_status = normalize_cell(mapped["ai_decision_status"])
            status = normalize_cell(mapped["status"])

            answer.update!(
              ai_decision_body: mapped["ai_decision_body"].presence || answer.ai_decision_body,
              ai_decision_status: AI_DECISION_STATUS_MAP[ai_decision_status] || answer.ai_decision_status,
              status: STATUS_MAP[status] || answer.status
            )

            create_answer_version(answer)
            updated_count += 1
          rescue => e
            Rails.logger.error { "ImportAiDecisionsJob error at row #{i}: #{e.message}" }
            failed_rows << i
          end
        end

        build_summary_for_stats(total_rows, updated_count, failed_rows)
        notify_receiver_about_answers_ai_decision_update
      ensure
        @attachment.destroy! if @attachment.present?
      end

      private

      def create_answer_version(answer)
        Decidim::CustomAi::AnswerVersion.create!(
          answer:,
          user: @user,
          ai_decision_body: answer.ai_decision_body,
          ai_decision_status: answer.ai_decision_status,
          status: answer.status
        )
      end

      def build_summary_for_stats(total, updated, failed_rows)
        failed_count = failed_rows.size
        updated_percent = ((updated.to_f / total) * 100).round(2)
        failed_percent = ((failed_count.to_f / total) * 100).round(2)

        @summary_html = <<~HTML
          <p>Liczba rekordów do importu: #{total}</p>
          <p>Liczba oraz procent zaktualizowanych uwag: #{updated} (#{updated_percent}%)</p>
          <p>Liczba oraz procent niezaktualizowanych uwag z powodu błędów: #{failed_count} (#{failed_percent}%)</p>
          <p>Lista pozycji (nr wierszy), które nie zostały zaktualizowane: #{failed_rows.join(", ").presence || "brak"}</p>
        HTML
      end

      def notify_receiver_about_answers_ai_decision_update
        Decidim::CoreExtended::TemplatedMailer.notify(
          "decidim_forms_answers_import_ai_decision",
          @user,
          { answers_import_summary: @summary_html }
        ).deliver_later
      end

      def normalize_cell(value)
        return "" if value.blank?
        value.to_s.strip.downcase
      end
    end
  end
end
