# frozen_string_literal: true

# Class Decorator - Extending Decidim::Meetings::MeetingListItemCell
#
# Decorator implements additional functionalities to the Cell
# and changes existing methods.
# TODO: upgrade v028! poprawic lub usunac
# Decidim::Meetings::MeetingListItemCell.class_eval do
#   private
#
#   def resource_date_time
#     str = l model.start_time, format: :decidim_day_of_year
#     str += ", "
#     str += l model.start_time, format: :time_of_day
#     str += "-"
#     str += l model.end_time, format: :time_of_day
#     str += ", "
#     str += l model.start_time, format: '%A'
#     str
#   end
# end
