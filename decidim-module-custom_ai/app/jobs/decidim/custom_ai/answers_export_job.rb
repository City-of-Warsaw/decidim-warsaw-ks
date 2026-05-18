# frozen_string_literal: true

module Decidim
  module CustomAi
    class AnswersExportJob < ApplicationJob
      include Decidim::EmailChecker

      queue_as :events

      def perform(user, answer_ids)
        answers = Decidim::Forms::Answer.where(id: answer_ids)
        serializer = Decidim::CustomAi::AnswersSerializer.new

        xlsx_data = generate_xlsx_data(serializer, answers)
        filename = "Lista odpowiedzi w ankiecie #{Date.current}.xlsx"
        content_type = "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
        attachment = Decidim::Attachment.new(
          attached_to: answers.first.questionnaire,
          title: { "pl": filename },
          content_type:
        )
        attachment.file.attach(
          io: StringIO.new(xlsx_data),
          filename:,
          content_type:
        )
        attachment.save!

        answers_export_link =  Rails.application.routes.url_helpers.rails_blob_url(attachment.file, host: Decidim::Organization.first.host)
        notify_receiver_about_answers_export(answers_export_link, user)
      end

      private

      def notify_receiver_about_answers_export(answers_export_link, receiver)
        return unless valid_email?(receiver.email)

        Decidim::CoreExtended::TemplatedMailer.notify(
          "decidim_forms_answers_export",
          receiver,
          { answers_export_link: }
        ).deliver_later
      end

      def generate_xlsx_data(serializer, answers)
        package = Axlsx::Package.new
        wb = package.workbook

        wrap_text = wb.styles.add_style(alignment: { wrap_text: true })
        right_align = wb.styles.add_style(alignment: { horizontal: :right })
        text_style = wb.styles.add_style(format_code: "@")

        wb.add_worksheet(name: "Lista") do |sheet|
          sheet.add_row serializer.headers

          serializer.serialize_all(answers).each do |row_hash|
            row = sheet.add_row serializer.ordered_values(row_hash)

            serializer.columns_order.each_with_index do |column, col_index|
              cell = row.cells[col_index]

              cell.style = wrap_text if serializer.columns_definition[column][:wrap_text]
              cell.style = right_align if serializer.column_alignment(column) == :right

              if serializer.columns_definition[column][:convert_to_text]
                cell.type = :string
                cell.value = row_hash[column].to_s
                cell.style = text_style
              end
            end
          end

          sheet.column_widths *serializer.columns_widths
        end

        package.to_stream.read
      end
    end
  end
end
