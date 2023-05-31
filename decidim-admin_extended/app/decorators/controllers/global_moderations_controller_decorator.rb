# frozen_string_literal: true

Decidim::Admin::GlobalModerationsController.class_eval do
  private

  # Overwritten decidim method
  #
  # Added fetch of all moderations for user that is ad_admin
  #
  # Returns: ActiveRecord
  def collection
    @collection ||=
      if params[:hidden]
        current_user.ad_admin? ? Decidim::Moderation.where.not(hidden_at: nil) : moderations_for_user.where.not(hidden_at: nil)
      else
        current_user.ad_admin? ? Decidim::Moderation.where(hidden_at: nil) : moderations_for_user.where(hidden_at: nil)
      end
  end

  def reportable
    @reportable ||= if current_user.ad_admin?
                      Decidim::Moderation.find(params[:id]).reportable
                    else
                      moderations_for_user.find(params[:id]).reportable
                    end
  end
end