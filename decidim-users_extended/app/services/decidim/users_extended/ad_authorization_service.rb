# frozen_string_literal: true

module Decidim
  module UsersExtended
    class AdAuthorizationService
      GROUP_MATCH = /CN=#{ENV['AD_BASE_FILTER']}*/.freeze

      # Public: Initializes the command.
      #
      # login    - user login from AD
      # password - user AD password
      def initialize(login, password)
        @login = login
        @password = password

        @ad_service = Decidim::UsersExtended::AdService.new
      end

      def call
        return false if @login.blank? || @password.blank?

        @ad_user = @ad_service.get_ad_user(@login)
        return unless ad_user

        # validate password with AD
        return unless ad_user_authenticated?
        update_or_create_user(ad_user)

        # check if user has valid role in system
        return unless ad_user_authorized?

        @user
      end

      attr_accessor :ad_user
      attr_reader :user

      def ad_user_authenticated?
        @ad_service.initialize_ldap_con(ad_user.ad_dn, @password).bind
      end

      def ad_user_authorized?
        !!ad_user_role(ad_user)
      end

      def ad_user_role(ad_user)
        @user_role ||= ad_user.find_ad_group_for(GROUP_MATCH)
      end

      # Return found user or create new one for
      def update_or_create_user(ad_user)
        @user = find_user(ad_user)
        if @user
          update_user(ad_user)
        else
          @user = create_user(ad_user)
        end
        @user
      end

      # Create new user form AD data
      def create_user(ad_user)
        password = gen_password
        user = Decidim::User.new(
          email: ad_user.email,
          ad_name: ad_user.ad_name,
          name: ad_user.first_name,
          nickname: gen_nickname(ad_user),
          first_name: ad_user.first_name,
          last_name: ad_user.last_name,
          office_name: ad_user.office_name,
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
          first_name: ad_user.first_name,
          last_name: ad_user.last_name,
          office_name: ad_user.office_name,
          ad_name: ad_user.ad_name,
          ad_role: ad_user_role(ad_user),
          # fix for all the invitations that were sent by mistake
          confirmed_at: DateTime.current,
          confirmation_sent_at: nil,
          confirmation_token: nil,
          ad_access_deactivate_date: ad_user_authorized? ? nil : Time.current,
          password_updated_at: Time.current
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
      def unify_letters(str)
        str.tr('ąĄęĘćĆłŁńŃóÓśŚźżŻ', 'aAeEcClLnNoOsSzzZ').delete(' .')
      end

      # Generate nickname from first name and last name
      def gen_nickname(ad_user)
        unify_letters("#{ad_user.first_name}-#{ad_user.last_name}-#{Time.current.to_i}".downcase.first(20))
      end

      # Generate random password
      # Why? Password is required for Decidim user, but it is never used for AD users login
      def gen_password
        plain = []
        chars = ("a".."z").to_a
        3.times { |i| plain << chars[rand(chars.size - 1)] }

        chars = ("A".."Z").to_a
        3.times { |i| plain << chars[rand(chars.size - 1)] }

        chars = ("0".."9").to_a
        3.times { |i| plain << chars[rand(chars.size - 1)] }

        chars = ["$", "!", "@", "#", "%", "*"]
        1.times { |i| plain << chars[rand(chars.size - 1)] }

        plain.shuffle.join
      end
    end
  end
end
