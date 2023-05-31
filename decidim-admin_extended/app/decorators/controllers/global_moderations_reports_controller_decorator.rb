# frozen_string_literal: true

Decidim::Admin::GlobalModerations::ReportsController.class_eval do
  private

  # Overwritten decidim method
  #
  # Added fetch of all moderations for user that is ad_admin
  #
  # Returns: ActiveRecord
  def moderation
    @moderation ||= if current_user.ad_admin?
                      Decidim::Moderation.find_by(id: params[:moderation_id])
                    else
                      moderations_for_user.find_by(id: params[:moderation_id])
                    end
  end
end