class AddToDbThisYearMeetingsDurationStat < ActiveRecord::Migration[6.1]
  def up
    sys_name = 'this_year_meetings_duration'
    return if Decidim::AdminExtended::Statistic.exists?(sys_name: sys_name)

    stat = Decidim::AdminExtended::Statistic.create!(
      name: 'Czas trwania spotkań od początku roku',
      sys_name: sys_name
    )
    organization = Decidim::Organization.first
    if organization
      stat.update_column(:count, stat.count_published) if stat.respond_to?(:count_published)
    end
  end
end