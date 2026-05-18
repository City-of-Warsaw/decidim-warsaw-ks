# frozen_string_literal: true

class UpdateConsultationStatusForAllProcesses < ActiveRecord::Migration[7.0]
  disable_ddl_transaction!

  def up
    say_with_time "Updating consultation status for all participatory processes" do
      Decidim::ParticipatoryProcess.find_each do |process|
        process.set_consultation_status
      rescue StandardError => e
        Rails.logger.error "Failed to update process #{process.id}: #{e.message}"
      end
    end
  end

  def down
    # no-op
  end
end
