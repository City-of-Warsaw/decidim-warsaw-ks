# frozen_string_literal: true

# OVERWRITTEN DECIDIM CONTROLLER
Decidim::ProfilesController.class_eval do

  # overwritten method
  # if current user is logged in, redirect to activity path, just like previewing any other user
  def show
    # return redirect_to profile_timeline_path(nickname: params[:nickname]) if profile_holder == current_user
    return redirect_to profile_members_path if profile_holder.is_a?(Decidim::UserGroup)

    redirect_to profile_activity_path(nickname: params[:nickname])
  end
end
