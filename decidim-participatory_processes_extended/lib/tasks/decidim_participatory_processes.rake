# frozen_string_literal: true

namespace :decidim_participatory_processes do
  desc "Turn off outdated step and activate next automatically in participatory processes"
  task :check_steps, [] => :environment do
    Decidim::ParticipatoryProcessesExtended::ActivateStepJob.perform_now
  end
end
