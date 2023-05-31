# frozen_string_literal: true

Decidim::User.class_eval do

  Decidim::User.const_set("AD_ROLES", %w(admin koordynator moderator ekspert).freeze)
  Decidim::User.const_set("GENDERS", %w(male female other).freeze)
  Decidim::User.const_set("AGE_RANGES", %w(under_20 between_21_30 between_31_40 between_41_50 over_50).freeze)

  belongs_to :district, foreign_key: :main_scope_id, class_name: "Decidim::Scope", optional: true

  scope :with_ad_role,     -> { where.not(ad_role: nil) }
  scope :admins,           -> { where("ad_role LIKE ?", '%admin') }

  # devise configuration
  def self.allow_unconfirmed_access_for
    0.days
  end

  # functions for assigning AD roles
  def ad_system?
    ad_role == 'Decidim_ks_system'
  end

  def ad_admin?
    ad_role && ad_role.include?("_admin")
  end

  def ad_coordinator?
    ad_role && ad_role.include?("_koordynator")
  end

  def ad_moderator?
    ad_role && ad_role.include?("_moderator")
  end

  def ad_expert?
    ad_role && ad_role.include?("_ekspert")
  end

  def ad_role_name
    return unless ad_role

    ad_role.match(/Decidim_ks_(admin|koordynator|moderator|ekspert)/)[1] rescue nil
  end

  def role_name
    case ad_role_name
    when 'admin' then 'Administrator'
    when 'koordynator' then 'Koordynator'
    when 'moderator' then 'Moderator'
    when 'ekspert' then 'Ekspert'
    else
      "nieznana rola: #{ad_role}"
    end
  end

  def has_ad_role?
    return unless ad_role

    Decidim::User::AD_ROLES.include?(ad_role.split('_')[-1])
    # ad_role_name
  end

  def name_and_surname
    "#{name} (#{role_name})"
  end

  alias_method :ad_full_name, :name_and_surname

  # tags

  def interested_tags_ids
    extended_data["interested_tags"] || []
  end

  def interested_tags
    @interested_tags ||= organization.tags.where(id: interested_tags_ids)
  end

  # conversations

  def accepts_conversation?(user)
    false
  end
end
