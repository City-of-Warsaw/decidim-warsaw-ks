# frozen_string_literal: true

# Class Decorator - Extending Decidim::Meetings::MeetingsMapCell
#
# Decorator implements additional functionalities to the Cell
# and changes existing methods.
Decidim::Meetings::MeetingsMapCell.class_eval do
  def show
    return unless Decidim::Map.available?(:geocoding, :dynamic)

    render :show_new
  end
end
