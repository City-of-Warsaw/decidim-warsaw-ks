# frozen_string_literal: true

# OVERWRITTEN CLASS CELL
Decidim::ProfileCell.class_eval do
  # overwritten method
  # render same view for previewing current user just as previewing any other user from admin panel
  def show
    render :show_new
  end

  # overwritten method
  # in case of current user:
  # render same view for previewing current user just as previewing any other user from admin panel
  def profile_tabs
    return render :user_group_tabs if profile_holder.is_a?(Decidim::UserGroup)
  end
end
