# frozen_string_literal: true

Decidim::CardMetadataCell.class_eval do
  # overwritten method
  # cut zero out from finished process with its end date
  # add custom scenario when current date == end date
  def progress_text
    return if progress_value.blank?

    @progress_text ||= if start_date.present? && current_date < start_date
                         t("not_started", scope: "decidim.metadata.progress")
                       elsif end_date.blank?
                         t("active", scope: "decidim.metadata.progress")
                       elsif current_date < end_date
                         t("remaining", scope: "decidim.metadata.progress", time_distance: distance_of_time_in_words(current_date, end_date))
                       elsif current_date.to_date == end_date.to_date
                         "Konsultacje trwają do dziś"
                       else
                         t("finished", scope: "decidim.metadata.progress", end_date: l(end_date.to_date, format: :decidim_short_cut_zero))
                       end
  end
end
