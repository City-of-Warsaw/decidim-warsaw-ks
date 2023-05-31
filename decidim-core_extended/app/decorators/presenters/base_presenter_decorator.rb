# frozen_string_literal: true

# OVERWRITTEN DECIDIM CLASS
Decidim::Log::BasePresenter.class_eval do
  private

  # added action logs column extra for processes logs
  delegate :extra, to: :action_log

  # overwritten method
  # added custom params for processes actions log concerning about tags & report files
  # added custom params for titles actions log concerning about informations, consultation requests, info_articles, pages
  def i18n_params
    {
      user_name: user_presenter.present,
      resource_name: resource_presenter.try(:present),
      space_name: space_presenter.present,
      # custom:
      process_was_files: process_was_files,
      process_current_files: process_current_files,
      process_was_tags: process_was_tags,
      process_current_tags: process_current_tags,
      banner_img: banner_img
    }
  end

  def process_was_files
    if action_log && action_log.extra && action_log.extra["report_files"]
      action_log.extra["report_files"]["was_files"]
    end
  end

  def process_current_files
    if action_log && action_log.extra && action_log.extra["report_files"]
      action_log.extra["report_files"]["current_files"]
    end
  end

  def process_was_tags
    if action_log && action_log.extra && action_log.extra["tags"]
      action_log.extra["tags"]["was_tags"]
    end
  end

  def process_current_tags
    if action_log && action_log.extra && action_log.extra["tags"]
      action_log.extra["tags"]["current_tags"]
    end
  end

  def banner_img
    if action_log && action_log.extra && action_log.extra["banner_img"]
      action_log.extra["banner_img"]["original_filename"]
    end
  end
end
