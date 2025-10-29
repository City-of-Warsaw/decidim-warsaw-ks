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
      # example: "CN=Kowlaski Jan,OU=Codeshine/Decidim,OU=Contractors,OU=Urzad Miasta Warszawy,DC=bzmw,DC=gov,DC=pl"
      def ad_dn
        @user_attrs.dn
      end

      # return login to AD system
      def ad_name
        @user_attrs.samaccountname.first
      end

      # return user roles
      def ad_groups
        # "CN=decidim_bo_bem_koord,OU=Decidim_BO,OU=.SecurityGroups,OU=.Konta Specjalne,OU=Urzad Miasta Warszawy,DC=bzmw,DC=gov,DC=pl"
        # "CN=Decidim_ks_koordynator,OU=Decidim_KS,OU=.SecurityGroups,OU=.Konta Specjalne,OU=Urzad Miasta Warszawy,DC=bzmw,DC=gov,DC=pl"
        @user_attrs.memberof
      end

      # return role in system for system group match regexp
      def find_ad_group_for(group_match)
        ad_user_group = ad_groups.find{ |g| g.match(group_match) }
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

      def office_name
        @user_attrs.physicaldeliveryofficename.first
      end

    end
  end
end
