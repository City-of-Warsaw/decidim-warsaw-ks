# frozen_string_literal: true

# Class Decorator - Extending Decidim::ParticipatoryProcesses::ContentBlocks::HighlightedProcessesCell
#
# Decorator implements additional functionalities to the Cell
# and changes existing methods.
Decidim::ParticipatoryProcesses::ContentBlocks::HighlightedProcessesCell.class_eval do
  def show
    render :show_new
  end

  def show_current_max
    highlighted_processes_max_results
  end

  def highlighted_processes
    @highlighted_processes ||= if highlighted_processes_max_results.zero?
                                 Decidim::ParticipatoryProcess.none
                               else
                                 Decidim::ParticipatoryProcess.on_main_page
                                                              .order_for_main_page
                                                              .includes(:area, :scope)
                                                              .limit(highlighted_processes_max_results)

                               end
  end
end
