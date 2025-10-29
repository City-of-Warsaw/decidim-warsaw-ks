# frozen_string_literal: true

namespace :decidim do
  namespace :admin_extended do
    desc 'Update all counters for for table: decidim_admin_extended_statistics'
    task :update_statistics => :environment do |_task|
      Decidim::AdminExtended::Statistic.update_counts
    end
  end
end
