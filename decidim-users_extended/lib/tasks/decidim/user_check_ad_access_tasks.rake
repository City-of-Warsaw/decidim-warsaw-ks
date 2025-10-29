#frozen_string_literal: true

desc 'Task for checking if user have access for AD'
task user_check_ad_access: :environment do
  GROUP_MATCH = /CN=#{ENV['AD_BASE_FILTER']}*/.freeze

  Decidim::User.where.not(ad_name: nil).each do |user|
    ad_user = Decidim::UsersExtended::AdService.new.get_ad_user(user.ad_name)
    unless ad_user
      if user.ad_access_deactivate_date.nil?
        user.update(ad_access_deactivate_date: Time.current)
        create_log(user, 'auto_deactivate_ad_user')
      end
      next
    end

    ad_user_role = ad_user.find_ad_group_for(GROUP_MATCH)
    if ad_user_role
      user.update(ad_role: ad_user_role)
      if user.ad_access_deactivate_date.present?
        create_log(user, 'auto_activate_ad_user')
        user.update(ad_access_deactivate_date: nil)
      end
    else
      if user.ad_access_deactivate_date.nil?
        create_log(user, 'auto_deactivate_ad_user')
        user.update(ad_access_deactivate_date: Time.current)
      end
    end
  end
end

def create_log(resource, log_type)
  Decidim.traceability.perform_action!(
    log_type,
    resource,
    resource,
    visibility: 'admin-only'
  )
end