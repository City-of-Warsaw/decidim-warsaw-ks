# frozen_string_literal: true

module Decidim
  module UsersExtended
    class AdAuthorizationService

      GROUP_MATCH = /CN=Decidim_ks_*/
      # GROUP_MATCH = /CN=#{ENV['AD_BASE_FILTER']}*/

      # Public: Initializes the command.
      #
      # password - user AD password
      def initialize(login, password)
        @login = login
        @password = password

        @ad_service = Decidim::UsersExtended::AdService.new
      end

      def call
        return false if @login.blank? || @password.blank?

        @ad_user = @ad_service.get_ad_user(@login)
        return unless @ad_user

        # validate password with AD
        return unless ad_user_authenticated?

        # check if user has valid rol in system
        return unless ad_user_role(@ad_user)

        find_or_create_user(@ad_user)
        update_user(@ad_user)
        @user
      end

      attr_accessor :ad_user
      attr_reader :user

      def ad_user_role(ad_user)
        ad_user.find_ad_role_for(GROUP_MATCH)
      end

      def ad_user_authenticated?
        @ad_service.initialize_ldap_con(@ad_user.ad_dn, @password).bind
      end

      # Return found user or create new one for
      def find_or_create_user(ad_user)
        @user = find_user(ad_user) || create_user(ad_user)
      end

      # Create new user form AD data
      def create_user(ad_user)
        password = gen_password
        user = Decidim::User.new(
          email: ad_user.email,
          ad_name: ad_user.ad_name,
          name: ad_user.first_name,
          nickname: gen_nickname(ad_user),
          # first_name: @ad_user.first_name, # tych pol nie ma w KS
          # last_name: @ad_user.last_name,   # tych pol nie ma w KS
          password: password,
          password_confirmation: password,
          organization: Decidim::Organization.first,
          tos_agreement: true, # co to?
          locale: 'pl',
          # wylaczamy zapraszanie https://www.py4u.net/discuss/1231180
          skip_invitation: true, # to nie potrzebne
          confirmed_at: DateTime.current, # to zapewnie, ze potwierdzenie konta nie jest wysylane
          accepted_tos_version: Decidim::Organization.last.tos_version, # warunko korzystania z serwisu
          admin_terms_accepted_at: DateTime.current # warunki bycia administratorem
        )
        user.save(validate: false)
        user
      end

      # Find user in system by ad_name or e-mail
      def find_user(ad_user)
        Decidim::User.find_by(ad_name: ad_user.ad_name).presence || Decidim::User.find_by(email: ad_user.email)
      end

      # Update user's data from AD
      def update_user(ad_user)
        return unless @user

        @user.update_columns(
          email: ad_user.email,
          admin: true,
          nickname: user.nickname.presence || gen_nickname(ad_user),
          # first_name: ad_user.first_name, # tych pol nie ma w KS
          # last_name: ad_user.last_name,   # tych pol nie ma w KS
          ad_name: ad_user.ad_name,
          ad_role: ad_user_role(ad_user),
          # fix for all the invitations that were sent by mistake
          confirmed_at: DateTime.current,
          confirmation_sent_at: nil,
          confirmation_token: nil
        )
      end

      def authenticate(login, password)
        if login && password
          ldap = AdService.new

          ldap.authenticate(login, password)
          user_attrs = ldap.user_attrs
          initialize_ldap_con(user_attrs.dn, password).bind
        end
      end

      # Remove polish letters from string
      def unify_polish_letters(str)
        str.gsub(' ', '').gsub('ą', 'a').gsub('ę', 'e').gsub('ć', 'c').gsub('Ć', 'C').gsub('ł', 'l').gsub('Ł', 'L').
          gsub('ń', 'n').gsub('Ń', 'N').gsub('ó', 'o').gsub('ś', 's').gsub('Ś', 'S').
          gsub('ź', 'z').gsub('ż', 'z').gsub('Ż', 'Z').gsub('.', '')
      end

      # Generate nickname from first and last name
      def gen_nickname(ad_user)
        unify_polish_letters("#{ad_user.first_name}-#{ad_user.last_name}-#{Time.current.to_i}".first(20))
      end

      # Generate random pasword
      def gen_password
        "#{::Faker::Lorem.word}#{::Faker::Number.between(from: 0, to: 9)}#{::Faker::Lorem.word}#{::Faker::Number.between(from: 0, to: 9)}"
      end

      # Test method
      # #########################################
      # testowa funkcja do znajdowania uzytkownika
      def find_user_from_ad(ad_name)
        u = Decidim::User.where.not(ad_name: ad_name)
        user_attrs = ad_service.get_user_info(u.ad_name)
        first_name = user_attrs.givenname.first
        last_name = user_attrs.sn.first
        u

        # GROUP_MATCH = /CN=Decidim_ks_*/
        login, password = '', ''
        ad_service = Decidim::UsersExtended::AdService.new
        ad_user = ad_service.get_ad_user(login)
        ad_service.initialize_ldap_con(ad_user.ad_dn, password).bind
        ad_service.authenticate('', '')

        # Decidim::User.where.not(ad_name: nil).each do |u|
        #   user_attrs = ad_service.get_user_info(u.ad_name)
        #   first_name = user_attrs.givenname.first
        #   last_name = user_attrs.sn.first
        #   u.name = first_name
        #   u.first_name = first_name
        #   u.last_name = last_name
        #   u.nickname = unpolish_letters("#{first_name}-#{last_name}-#{Time.current.to_i}".first(20))
        #   u.save
        # end
      end

    end
  end
end
