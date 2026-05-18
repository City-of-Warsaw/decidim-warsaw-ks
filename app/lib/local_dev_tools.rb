# frozen_string_literal: true

# Wyczyszczenie zmienia podstawowe dane organizacji + czysci wszystkie prawdopodobne miejsca gdzie uzytkownicy pozostawili swoje dane osobowe
# Dodatkowo tworzy userow z 3 podstatowymi typami admina
# admin@example.com / moderator@example.com / koordynator@example.com z haslem Test12345!
#
class LocalDevTools
  require 'faker'

  # Przygotowuje baze produkcyjna do sprawdzenia lokalnie
  # @param email - to email lokalnego uzytkownika, admina
  def setup_local_production(email)
    setup_local_organization
    reset_local_passwords(email)
  end

  # Przygotowuje baze produkcyjna i nadpisuje wrazliwe dane
  # Ustawia admina: email: 'admin@example.com', password: 'Test12345!'
  def setup_for_local
    setup_local_organization
    setup_test_users
    reset_users_notifications
    anonymize_users_data
    anonymize_others
    clean_up_versions
  end

  # Czysci dane serwera SMTP w organizacji
  def setup_local_organization
    Decidim::Organization.first.update(
      host: 'localhost',
      smtp_settings: { 'from' => '', 'port' => '', 'address' => '', 'user_name' => '', 'from_email' => '', 'from_label' => '', 'encrypted_password' => nil },
      newsletter_smtp_settings: { 'from' => '', 'port' => '', 'address' => '', 'user_name' => '', 'from_email' => '', 'from_label' => '', 'encrypted_password' => nil }
    )
  end

  # Ustawia wszystkim userom haslo takie samo jak znalezionego uzytkownika
  def reset_local_passwords(email)
    my_user = Decidim::User.find_by email: email
    raise 'Brak uzytkownika' unless my_user

    Decidim::User.update_all(encrypted_password: my_user.encrypted_password)
  end

  # LocalTools.new.setup_test_users
  def setup_test_users
    Decidim::User.where(ad_role: "#{ENV['AD_BASE_FILTER']}_moderator").first.update_column(:email, 'moderator@example.com')
    Decidim::User.where(ad_role: "#{ENV['AD_BASE_FILTER']}_koordynator").first.update_column(:email, 'koordynator@example.com')

    user = Decidim::User.find_by(ad_role: "#{ENV['AD_BASE_FILTER']}_admin")
    user.update_column(:email, 'admin@example.com')
    user.update(password: 'Test12345!')
    Decidim::User.update_all(encrypted_password: user.encrypted_password)
    Decidim::User.where.not(ad_name: nil).each do |user|
      user.update(ad_name: Faker::Internet.username(specifier: 10, separators: ['_']), password_updated_at: Time.now)
    end
  end

  def reset_users_notifications
    Decidim::Notification.delete_all

    Decidim::User.update_all(
      newsletter_token: nil,
      newsletter_notifications_at: nil,
      notification_settings: {},
      notifications_sending_frequency: "real_time",
      extended_data: {},
      email_on_moderations: false
    )
  end

  def anonymize_users_data(without_email = nil)
    Decidim::User.transaction do
      users = Decidim::User
      users = users.where.not(email: without_email) if without_email
      users.find_each do |user|
        user.update_columns(
          email: "example-#{user.id}-@example.com",
          # nickname: '' 2 BO jest generowany
          first_name: Faker::Name.first_name,
          last_name: Faker::Name.last_name,
          name: "mieszkaniec_#{user.id}",
          office_name: "",
          zip_code: Faker::Address.zip_code
        )
      end
    end
    true
  end

  def anonymize_others
    Decidim::Remarks::Remark.all.each do |remark|
      remark.update_column(:signature, Faker::Name.name)
      remark.update_column(:email, Faker::Internet.email)
    end

    Decidim::Comments::Comment.all.each do |comment|
      comment.update_column(:signature, Faker::Name.name)
      comment.update_column(:email, Faker::Internet.email)
    end

    Decidim::CoreExtended::EmailFollow.all.each do |follow|
      follow.update_column(:email, Faker::Internet.email)
    end

    Decidim::ExpertQuestions::UserQuestion.all.each do |question|
      question.update_column(:signature, Faker::Name.name)
      question.update_column(:email, Faker::Internet.email)
    end

    Decidim::StudyNotes::StudyNote.all.each do |question|
      question.update_column(:first_name, Faker::Name.first_name)
      question.update_column(:email, Faker::Internet.email)
      question.update_column(:last_name, Faker::Name.last_name)
    end

    Decidim::GeneralPlanRequests::GeneralPlanRequest.all.each do |question|
      question.update_columns(
        submitter_data_first_name: Faker::Name.first_name,
        submitter_data_last_name: Faker::Name.last_name,
        submitter_data_org_name: "",
        submitter_data_country: "",
        submitter_data_voivodeship: "",
        submitter_data_county: "",
        submitter_data_community: "",
        submitter_data_street: "",
        submitter_data_street_number: "",
        submitter_data_flat_number: "",
        submitter_data_city: "",
        submitter_data_zip_code: "00-000",
        submitter_data_email: Faker::Internet.email,
        submitter_data_phone_number: "",
        submitter_data_epuap_delivery_address: "",
        mailing_address_data_voivodeship: "",
        mailing_address_data_county: "",
        mailing_address_data_community: "",
        mailing_address_data_street: "",
        mailing_address_data_street_number: "",
        mailing_address_data_flat_number: "",
        mailing_address_data_city: "",
        mailing_address_data_zip_code: "00-000",
        attorney_data_first_name: Faker::Name.first_name,
        attorney_data_last_name: Faker::Name.last_name,
        attorney_data_country: "",
        attorney_data_voivodeship: "",
        attorney_data_county: "",
        attorney_data_community: "",
        attorney_data_street: "",
        attorney_data_street_number: "",
        attorney_data_flat_number: "",
        attorney_data_city: "",
        attorney_data_zip_code: "00-000",
        attorney_data_email: Faker::Internet.email,
        attorney_data_phone_number: "",
        attorney_data_epuap_delivery_address: ""
      )
    end
  end

  # testowa funkcja do znajdowania uzytkownika po ad_name
  def find_ad_user(ad_name)
    user = Decidim::User.find_by(ad_name: ad_name)
    raise 'Brak uzytkownika z AD_NAME' unless user

    ad_service = Decidim::UsersExtended::AdService.new
    user_attrs = ad_service.get_user_info(user.ad_name)
    ad_user = Decidim::UsersExtended::AdUser.new(user_attrs)
    ap ad_user
    group_match = /CN=#{ENV['AD_BASE_FILTER']}*/
    ad_user.find_ad_group_for(group_match)
  end

  # wyszukuje i podmienia w linkach signed_id w tresci za pomoca regexp np.
  #   %r{/rails/active_storage/blobs/(?:redirect/)?([^/]+)/}
  #   lub
  #   %r{/repository/blobs/?([^/]+)/}
  def update_signed_id_in(content, link_regex)
    return unless content.match?(link_regex)

    content.scan(link_regex).each do |matched_arr|
      signed_id = matched_arr.first
      old_blob = ActiveStorage::Blob.find_signed!(signed_id)
      new_blob = ActiveStorage::Blob.where(service_name: 'amazon').where(byte_size: old_blob.byte_size).first
      puts "Old: #{old_blob.signed_id} \nnew-> #{new_blob.signed_id}"
      content.gsub!(signed_id, new_blob.signed_id)
    end
    content
  end

  # poprawia linki uploads/decidim/attachment/file/:ID
  def update_old_attachment_url_in(content)
    url_regex = %r{https://konsultacje\.um\.warszawa\.pl/uploads/decidim/attachment/file/\d+/[^'"\s<>]+}
    return unless content.match?(url_regex)

    id_regex = %r{/uploads/decidim/attachment/file/(\d+)/}
    urls = content.scan(url_regex)
    urls.each do |url|
      attachment = Decidim::Attachment.find url.scan(id_regex)[0][0]
      blob = ActiveStorage::Blob.where(service_name: 'amazon', byte_size: attachment.file_size, filename: attachment[:file]).first
      unless blob
        #list << process.slug
        puts "brakuje !!!!: #{attachment[:file]}"
        next
      end
      new_url = Rails.application.routes.url_helpers.rails_blob_url(blob, host: "https://konsultacje.um.warszawa.pl")
      # puts "Old: #{url} \nnew-> #{new_url}"
      content.gsub!(url, new_url)
    end
    content
  end

  # link_regex = %r{/rails/active_storage/blobs/(?:redirect/)?([^/]+)/}
  # link_regex = %r{/repository/blobs/?([^/]+)/}
  def fix_process_desc_images(link_regex)
    list = []
    Decidim::ParticipatoryProcess.order(:id).all.each do |process|
      puts "badam process: #{process.id}"
      content = process.description['pl']
      next if content.blank?
      next unless content.match?(link_regex)

      puts "aktualizuje1: #{process.id}"
      new_content = update_signed_id_in(content, link_regex)
      if new_content.present?
        process.update_columns(description: { pl: new_content })
      end
    end
    puts 'ok'
  end

  def fix_old_process_attachment_urls
    list = []
    Decidim::ParticipatoryProcess.order(:id).all.each do |process|
      puts "badam process: #{process.id}"
      content = process.description['pl']
      next if content.blank?

      new_content = update_old_attachment_url_in(content)
      if new_content.present?
        process.update_columns(description: { pl: new_content })
      end
    end
    puts 'ok'
  end

  def fix_old_component_settings_attachment_urls
    Decidim::Component.where(manifest_name: "custom_proposals").order(:id).each do |process|
      puts "badam process: #{process.id}"
      content = process.settings[:help_section_description]
      next if content.blank?

      new_content = update_old_attachment_url_in(content)
      if new_content.present?
        puts "aktualizuje: #{process.id}"
        process[:settings]["global"]["help_section_description"] = new_content
        process.update_columns(settings: process[:settings])
      end
    end
    puts 'ok'
  end

  # link_regex = %r{/rails/active_storage/blobs/(?:redirect/)?([^/]+)/}
  # link_regex = %r{/repository/blobs/?([^/]+)/}
  def fix_info_articles(link_regex)
    Decidim::AdUsersSpace::InfoArticle.all.each do |article|
      puts "dzialam: #{article.id}"
      next if article.body.blank?
      next unless article.body.match?(link_regex)

      content = update_signed_id_in(article.body, link_regex)
      next if content.blank?

      puts "aktualizuje: #{article.id}"
      article.update_columns(body: content)
    end
    puts 'ok'
  end

  # link_regex = %r{/rails/active_storage/blobs/(?:redirect/)?([^/]+)/}
  # link_regex = %r{/repository/blobs/?([^/]+)/}
  def fix_static_pages(link_regex)
    Decidim::StaticPage.all.each do |article|
      puts "dzialam: #{article.id}"
      next if article.content['pl'].blank?
      next unless article.content['pl'].match?(link_regex)

      content = update_signed_id_in(article.content['pl'], link_regex)
      next if content.blank?

      puts "aktualizuje: #{article.id}"
      article.update_columns(content: { pl: content })
    end
    puts 'ok'
  end


  private

  def clean_up_versions
    Decidim::ActionLog.delete_all
    ActiveRecord::Base.connection.execute("TRUNCATE Versions")
  end

end
