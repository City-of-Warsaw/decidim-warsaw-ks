# frozen_string_literal: true

# Mapowanie danych uzytkownika z Active Directory

module Decidim
  module UsersExtended
    class AdUser

      attr_reader :user_attrs

      def initialize(user_attrs)
        @user_attrs = user_attrs
      end

      # return String, DN from Active Directory
      def ad_dn
        @user_attrs.dn
      end

      # return login to AD system
      def ad_name
        @user_attrs.samaccountname.first
      end

      # return role in system for system group match regexp
      def find_ad_role_for(group_match)
        ad_user_group = @user_attrs.memberof.find{ |g| g.match(group_match) }
        return if ad_user_group.blank?

        ad_user_group.split(',').first.gsub('CN=','')
      end

      def email
        @user_attrs.mail.first.downcase
      end

      def first_name
        @user_attrs.givenname.first
      end

      def last_name
        @user_attrs.sn.first
      end

    end
  end
end
