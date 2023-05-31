# frozen_string_literal: true

Decidim::ContentBlocks::StatsCell.class_eval do

  def show
    render :show_new
  end

  def highlited(highlited_query)
    @chosen_stats = highlited_query ? stats.highlited : stats.not_highlited

    render :statistics
  end

  def stats
    @stats ||= Decidim::AdminExtended::Statistic.visible
  end
end
