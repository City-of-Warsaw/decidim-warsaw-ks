# frozen_string_literal: true

Decidim::FollowButtonCell.class_eval do
  def show
    render :show_new
  end

  def follow_for_registered_user
    render :for_registered_user
  end

  def follow_for_unregistered_user
    render :for_unregistered_user
  end

  private

  # Overwitten class to remove class
  def button_classes
    return "card__button secondary text-uppercase follow-button mb-none has-tip" if inline?

    extra_classes = ""
    # extra_classes += " active" if current_user_follows? # removed class
    extra_classes += begin
                       if large?
                         " button--sc"
                       else
                         " small"
                       end
                     end

    "button expanded button--icon follow-button secondary hollow #{extra_classes}"
  end
end