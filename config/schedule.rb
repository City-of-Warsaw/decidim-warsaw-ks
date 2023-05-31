# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron

# Example:
#
# set :output, "/path/to/my/cron_log.log"
#
# every 2.hours do
#   command "/usr/bin/some_great_command"
#   runner "MyModel.some_method"
#   rake "some:great:rake:task"
# end
#
# every 4.days do
#   runner "AnotherModel.prune_old_records"
# end

# Uruchomienie: bundle exec whenever

# Learn more: http://github.com/javan/whenever

# przypomnienie o konczacych sie procesach 2 dni wczesniej, kazdego dnia o 5 rano
every 1.day, at: '5:00 am' do
  runner "Decidim::ParticipatoryProcessesExtended::NotifyFollowersBefeoreProcessFinishJob.perform_now"
end
# 0 5 * * * /bin/bash -l -c 'cd /var/www/decidim/current && bundle exec bin/rails runner -e staging '\''Decidim::ParticipatoryProcessesExtended::NotifyFollowersBefeoreProcessFinishJob.perform_now'\'''


every 1.day, at: '6:00 am' do
  runner "Decidim::ParticipatoryProcessesExtended::NotifyFollowersBefeoreMeetingJob.perform_now"
end
# 0 6 * * * /bin/bash -l -c 'cd /var/www/decidim/current && bundle exec bin/rails runner -e staging '\''Decidim::ParticipatoryProcessesExtended::NotifyFollowersBefeoreProcessFinishJob.perform_now'\'''