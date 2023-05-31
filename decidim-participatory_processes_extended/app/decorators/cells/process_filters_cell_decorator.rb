# frozen_string_literal: true

# Class Decorator - Extending Decidim::ParticipatoryProcesses::ProcessFiltersCell
#
# Decorator implements additional functionalities to the Cell
# and changes existing methods.
module Decidim
  module ParticipatoryProcesses
    ProcessFiltersCell.class_eval do

      # Public: Overwritten method
      #
      # For changing styling, polish translations in this scope now include
      # HTML tags, so returned string has html_safe method added
      #
      # returns: translated String
      def title
        I18n.t(
          'found',
          scope: "decidim.participatory_processes.participatory_processes.filters.counters",
          count: process_count_by_filter[current_filter]
        ).html_safe
      end

      # Public: Overwritten method
      #
      # :date data for the filters is after changes passed via form
      # so it has to be read from params
      #
      # returns String - from ALL_FILTERS constant
      def current_filter
        params[:date].presence || model[:default_filter]
      end
    end
  end
end