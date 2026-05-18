# Uruchomienie:
#   bundle exec whenever
#
# Learn more: http://github.com/javan/whenever

set :environment, ENV['RAILS_ENV'] || 'development'
set :output, "/srv/www/decidim/current/log/cron_log.log"
set :path, "/srv/www/decidim/current"

# przypomnienie o konczacych sie procesach 2 dni wczesniej, kazdego dnia o 5 rano
every 1.day, at: '5:00 am' do
  runner "Decidim::ParticipatoryProcessesExtended::NotifyFollowersBefeoreProcessFinishJob.perform_now"
end

every 1.day, at: '5:00 am' do
  rake "decidim:admin_extended:update_statistics"
end

every 1.week, at: '1:30 am' do
  rake "sitemap:refresh"
end

every 1.day, at: '6:00 am' do
  runner "Decidim::ParticipatoryProcessesExtended::NotifyFollowersBeforeMeetingJob.perform_now"
end

# nasz proces do aktywacji odpowiedniego etapu w procesie
every 15.minutes do
  rake "decidim_participatory_processes:check_steps"
end

every 1.day, at: '4:30 am' do
  rake "rake user_check_ad_access"
end
