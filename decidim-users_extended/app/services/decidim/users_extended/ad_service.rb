# frozen_string_literal: true

# Grupy w AD maja nazwy:
# [

module Decidim
  module UsersExtended
    class AdService

      def initialize
        @ldap_host = ENV['AD_HOST']
        @ldap_port = ENV['AD_PORT']
        @ldap_user = ENV['AD_USER']
        @ldap_password = ENV['AD_PASSWORD']
        @base_dn = ENV['AD_BASE_DN']

        @attr_login = ENV['AD_ATTR_LOGIN']
        @attr_firstname = ENV['AD_ATTR_FIRSTNAME']
        @attr_lastname = ENV['AD_ATTR_LASTNAME']
        @attr_mail = ENV['AD_ATTR_MAIL']

        @project_base_filter = ENV['AD_BASE_FILTER']
      end

      attr_reader :user_attrs

      def authenticate(login, password)
        if login && password
          @user_attrs = user_attrs = get_user_info(login)
          initialize_ldap_con(user_attrs.dn, password).bind if @user_attrs&.dn
        end
      end

      def test_connection
        ldap_con = initialize_ldap_con
        ldap_con.open {}
      end

      def get_ad_user(login)
        user_attrs = get_user_info(login)
        AdUser.new(user_attrs) if user_attrs
      end

      def initialize_ldap_con(ldap_user=@ldap_user, ldap_password=@ldap_password)
        options = {
          :host => @ldap_host, :port => @ldap_port,
          encryption: {
            :method => :simple_tls,
            :tls_options => { :verify_mode => OpenSSL::SSL::VERIFY_NONE }},
          :auth => {
            :method => :simple,
            :username => ldap_user,
            :password => ldap_password
          }
        }
        Net::LDAP.new options
      end

      def get_user_info(login)
        ldap_con = initialize_ldap_con
        base_filter = Net::LDAP::Filter.eq("objectClass", "user")
        search_filter = base_filter & Net::LDAP::Filter.eq(@attr_login, login)
        # results = []
        result_attrs = ['dn', @attr_login, @attr_firstname, @attr_lastname, @attr_mail, "memberof", 'objectClass']
        attrs = nil
        ldap_con.search(:base => @base_dn, :filter => search_filter, :attributes => result_attrs) do |entry|
          attrs = entry
        end
        attrs
      end

      def get_all_groups
        ldap_con = initialize_ldap_con
        search_filter = Net::LDAP::Filter.begins("sAMAccountName", @project_base_filter)
        group_filter = Net::LDAP::Filter.eq("objectClass", "group")
        composite_filter = Net::LDAP::Filter.join(search_filter, group_filter)
        # result_attrs = ['dn', "sAMAccountName", "displayName"]
        result_attrs = ['dn', @attr_login, "displayName", "members", "description" ]
        attrs = []
        ldap_con.search(:base => @base_dn, :filter => composite_filter, :attributes => result_attrs) do |entry|
          attrs << entry
        end
        attrs
      end

      def import_all_groups
        ad_service = Decidim::UsersExtended::AdService.new
        # a = ad_service.get_all_groups
        # ad_group = a[0]
        groups = {}
        ad_service.get_all_groups.each do |ad_group|
          # dep_name = 'decidim_bo_osir_wol_podkoord'
          dep_name = ad_group.samaccountname.first
          # ap dep_name
          s = dep_name.gsub(@project_base_filter, '')
          %w"admin koord podkoord weryf edytor".each do |n|
            s = s.gsub("_#{n}", '')
          end
          dep_ad_name = s
          unless groups[dep_ad_name]
            # ap "brak #{dep_ad_name}"
            groups[dep_ad_name] = dep_ad_name
            unless Decidim::AdminExtended::Department.find_by ad_name: dep_ad_name
              # ap "tworze #{dep_ad_name}"
              name = ad_group.description.first.gsub('Budżet Obywatelski ', '').gsub(' - admin Grupa dostępu do systemu DECIDIM', '')
              Decidim::AdminExtended::Department.create(name: name, ad_name: dep_ad_name)
            end
          end
        end
      end

    end
  end
end
