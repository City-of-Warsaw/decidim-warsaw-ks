# frozen_string_literal: true

# Class Decorator - Extending Decidim::Meetings::MeetingSCell
#
# Decorator implements additional functionalities to the Cell
# and changes existing methods.
Decidim::Meetings::MeetingSCell.class_eval do
  def show
    render :show_new
  end
end
