# frozen_string_literal: true

Decidim::FlagModalCell.class_eval do
  def show
    render :show_new
  end

  def flag_user
    render :flag_user_new
  end
end