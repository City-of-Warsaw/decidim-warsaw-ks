# frozen_string_literal: true

Decidim::ContentBlocks::StatsCell.class_eval do
  def show
    render :show_new
  end

  def highlited(highlited_query)
    @chosen_stats = highlited_query ? stats.highlited : stats.not_highlited

    render :statistics
  end

  # overwritten method
  # change function completely
  # take our collection and for Client's request - not present all data
  def stats
    @stats ||= Decidim::AdminExtended::Statistic.excluding_hidden_stats.visible
  end

  private

  # overwritten method
  # make it nil
  def cache_hash
    nil
  end

  # overwritten method
  # expiry time only for production env
  def cache_expiry_time
    Rails.env.production? ? 10.minutes : 0
  end
end
