# frozen_string_literal: true

Decidim::ParticipatoryProcesses::ContentBlocks::HighlightedProcessesCell.class_eval do
  # overwritten method
  # rebuild method
  # fill it with processes set to the main page and impose a limit
  # published does not matter
  # status does not matter
  # hero img does not matter
  def highlighted_processes
    @highlighted_processes ||= if highlighted_processes_max_results.zero?
                                 []
                               else
                                 Decidim::ParticipatoryProcess.on_main_page
                                                              .order_for_main_page
                                                              .includes(:area, :scope)
                                                              .limit(highlighted_processes_max_results)
                               end
  end
end
