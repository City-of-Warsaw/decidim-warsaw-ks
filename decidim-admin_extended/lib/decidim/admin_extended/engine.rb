module Decidim
  module AdminExtended
    class Engine < ::Rails::Engine
      isolate_namespace Decidim::AdminExtended

      initializer "decidim.user_menu" do
        Decidim.menu :admin_settings_menu do |menu|
          menu.add_item :main_menu_items,
                        I18n.t("menu.customizing_menu", scope: "decidim.admin"),
                        decidim_admin_extended.main_menu_items_path,
                        icon_name: "direction-line",
                        position: 1.15,
                        if: allowed_to?(:update, :organization, organization: current_organization),
                        active: is_active_link?(decidim_admin_extended.main_menu_items_path)
          menu.add_item :tags,
                        I18n.t("menu.tags", scope: "decidim.admin"),
                        decidim_admin_extended.tags_path,
                        icon_name: "direction-line",
                        position: 1.45,
                        if: allowed_to?(:update, :organization, organization: current_organization),
                        active: is_active_link?(decidim_admin_extended.tags_path)
          menu.add_item :departments,
                        I18n.t("menu.departments", scope: "decidim.admin"),
                        decidim_admin_extended.departments_path,
                        icon_name: "direction-line",
                        position: 1.45,
                        if: allowed_to?(:update, :organization, organization: current_organization),
                        active: is_active_link?(decidim_admin_extended.departments_path)
          menu.add_item :mail_templates,
                        I18n.t("menu.mail_templates", scope: "decidim.admin"),
                        decidim_admin_extended.mail_templates_path,
                        icon_name: "direction-line",
                        position: 1.46,
                        if: allowed_to?(:update, :organization, organization: current_organization),
                        active: is_active_link?(decidim_admin_extended.mail_templates_path)
          menu.add_item :statistics,
                        I18n.t("menu.statistics", scope: "decidim.admin"),
                        decidim_admin_extended.statistics_path,
                        icon_name: "direction-line",
                        position: 1.65,
                        if: allowed_to?(:update, :organization, organization: current_organization),
                        active: is_active_link?(decidim_admin_extended.statistics_path)
          menu.add_item :banned_words,
                        I18n.t("menu.banned_words", scope: "decidim.admin"),
                        decidim_admin_extended.banned_words_path,
                        icon_name: "direction-line",
                        position: 1.75,
                        if: current_user.ad_admin?,
                        active: is_active_link?(decidim_admin_extended.banned_words_path)
          menu.add_item :hero_sections,
                        I18n.t("menu.hero_sections", scope: "decidim.admin"),
                        decidim_admin_extended.hero_sections_path,
                        icon_name: "direction-line",
                        position: 1.85,
                        if: current_user.ad_admin?,
                        active: is_active_link?(decidim_admin_extended.hero_sections_path)
          menu.add_item :additional_translations,
                        I18n.t("menu.additional_translations", scope: "decidim.admin"),
                        decidim_admin_extended.additional_translations_path,
                        icon_name: "folder-line",
                        position: 1.95,
                        if: current_user.ad_admin?,
                        active: is_active_link?(decidim_admin_extended.additional_translations_path)
        end
      end

      initializer "decidim_admin.menu" do
        # overwritten admin/users admin-sidebar-menu-settings - remove:
        # - user_groups
        # - impersonatable_users
        # - authorization_workflows
        Decidim.menu :admin_user_menu do |menu|
          menu.remove_item :user_groups
          menu.remove_item :impersonatable_users
          menu.remove_item :authorization_workflows
        end

        # Modify the existing menu item `:edit_organization` to support additional controller paths and show breadcrumb
        # Instead of re-adding or overwriting the menu item, we mutate it safely
        # by accessing internal variables (`@items`, `@active`)
        # to preserve all original configuration (icon, label, conditions, position, etc).
        # This is necessary because Decidim doesn't provide a public API
        # for modifying `active` routes after registration.
        Decidim.menu :admin_menu do |menu|
          items = menu.instance_variable_get(:@items)
          item = items.find { |i| i.identifier == :edit_organization }
          next unless item

          current_active = Array(item.instance_variable_get(:@active))

          current_first = Array(current_active[0])
          current_second = Array(current_active[1]) # usually empty

          # Append new controller paths
          current_first += %w(
            decidim/admin_extended/main_menu_items
            decidim/admin_extended/tags
            decidim/admin_extended/departments
            decidim/admin_extended/mail_templates
            decidim/admin_extended/statistics
            decidim/admin_extended/banned_words
            decidim/admin_extended/hero_sections
          )

          item.instance_variable_set(:@active, [current_first.uniq, current_second])
        end
      end

      initializer "decidim_static_pages_admin.menu" do
        Decidim.menu :admin_pages_sidebar_menu do |menu|
          menu.add_item :static_pages,
                        I18n.t("static_pages.title", scope: "decidim.admin"),
                        decidim_admin.static_pages_path,
                        active: is_active_link?(decidim_admin.static_pages_path) ||
                          is_active_link?(decidim_admin.static_page_topics_path),
                        icon_name: "direction-line",
                        if: true
          menu.add_item :contact_info_positions,
                        I18n.t("contacts.title", scope: "decidim.admin"),
                        decidim_admin_extended.contact_info_positions_path,
                        active: is_active_link?(decidim_admin_extended.contact_info_positions_path) ||
                          is_active_link?(decidim_admin_extended.contact_info_groups_path),
                        icon_name: "direction-line",
                        if: true
          menu.add_item :faqs,
                        I18n.t("faqs.title", scope: "decidim.admin"),
                        decidim_admin_extended.faqs_path,
                        active: is_active_link?(decidim_admin_extended.faqs_path) ||
                          is_active_link?(decidim_admin_extended.faq_groups_path) ,
                        icon_name: "direction-line",
                        if: true
        end
      end

      initializer "mobile_breadcrumb_root_menu" do
        Decidim.menu :mobile_menu do |menu|
          menu.add_item :faqs,
                        I18n.t("faqs.title", scope: "decidim.admin"),
                        decidim_core_extended.faqs_path,
                        active: is_active_link?(decidim_core_extended.faqs_path),
                        icon_name: "direction-line",
                        if: true

          menu.add_item :info_articles,
                        "Strefa koordynatora konsultacji", # sys_name for MainMenuItem
                        decidim_ad_users_space.info_articles_path,
                        position: 9,
                        active: is_active_link?(decidim_ad_users_space.info_articles_path, :inclusive),
                        if: !!current_user&.has_ad_role?
        end
      end

      # zakladki w admin/contact_info_positions
      initializer "decidim_contact_info_positions_admin.menu" do
        Decidim.menu :admin_contact_info_positions_menu do |menu|
          menu.add_item :contact_info_positions,
                        I18n.t("contacts.title", scope: "decidim.admin"),
                        decidim_admin_extended.contact_info_positions_path,
                        active: is_active_link?(decidim_admin_extended.contact_info_positions_path),
                        icon_name: "direction-line",
                        if: true
          menu.add_item :contact_info_groups,
                        I18n.t("contact_info_groups.title", scope: "decidim.admin"),
                        decidim_admin_extended.contact_info_groups_path,
                        active: is_active_link?(decidim_admin_extended.contact_info_groups_path),
                        icon_name: "direction-line",
                        if: true
        end
      end
      # zakladki w admin/faqs
      initializer "decidim_faq_admin.menu" do
        Decidim.menu :admin_faq_menu do |menu|
          menu.add_item :faqs,
                        I18n.t("faqs.title", scope: "decidim.admin"),
                        decidim_admin_extended.faqs_path,
                        active: is_active_link?(decidim_admin_extended.faqs_path),
                        icon_name: "direction-line",
                        if: true
          menu.add_item :faq_groups,
                        I18n.t("faq_groups.title", scope: "decidim.admin"),
                        decidim_admin_extended.faq_groups_path,
                        active: is_active_link?(decidim_admin_extended.faq_groups_path),
                        icon_name: "direction-line",
                        if: true
        end
      end

      initializer "decidim_admin_extended.register_resources" do
        Decidim.register_resource(:contact_info_positions) do |resource|
          resource.model_class_name = "Decidim::AdminExtended::ContactInfoPosition"
          resource.card = "decidim/admin_extended/contact_info_position"
          resource.searchable = true
        end

        Decidim.register_resource(:faq) do |resource|
          resource.model_class_name = "Decidim::AdminExtended::Faq"
          resource.card = "decidim/admin_extended/faq"
          resource.searchable = true
        end
      end
      
      initializer "decidim.core.newsletter_templates" do
        Decidim.content_blocks.register(:newsletter_template, :ks_custom) do |content_block|
          content_block.cell = "decidim/newsletter_templates/ks_custom"
          content_block.settings_form_cell = "decidim/newsletter_templates/ks_custom_settings_form"
          content_block.public_name_key = "decidim.newsletter_templates.ks_custom.name"
      
          content_block.images = [
            {
              name: :main_image,
              uploader: "Decidim::NewsletterTemplateImageUploader",
              preview: -> { ActionController::Base.helpers.asset_pack_path("media/images/newsletter-warsaw-image.jpg") }
            }
          ]
      
          content_block.settings do |settings|
            settings.attribute(
              :title,
              type: :text,
              translated: true,
              preview: -> { I18n.t("decidim.newsletter_templates.ks_custom.title_preview") }
            )
      
            settings.attribute(
              :lead,
              type: :text,
              translated: true,
              preview: -> { I18n.t("decidim.newsletter_templates.ks_custom.lead_preview") }
            )
            settings.attribute(
              :encouragement,
              type: :text,
              translated: true,
              preview: -> { I18n.t("decidim.newsletter_templates.ks_custom.encouragement_preview") }
            )
            settings.attribute(
              :introduction,
              type: :text,
              translated: true,
              preview: -> { I18n.t("decidim.newsletter_templates.ks_custom.introduction_preview") }
            )
            settings.attribute(
              :body,
              type: :text,
              translated: true,
              preview: -> { I18n.t("decidim.newsletter_templates.ks_custom.body_preview") }
            )
            settings.attribute(
              :cta_text,
              type: :text,
              translated: true,
              preview: -> { I18n.t("decidim.newsletter_templates.ks_custom.cta_text_preview") }
            )
            settings.attribute(
              :cta_url,
              type: :text,
              translated: true,
              preview: -> { "http://decidim.org" }
            )
            settings.attribute :footer, type: :text, editor: true
          end
      
          content_block.default!
        end

        Decidim.content_blocks.register(:newsletter_template, :ks_multi_process) do |content_block|
          content_block.cell = "decidim/newsletter_templates/ks_multi_process"
          content_block.settings_form_cell = "decidim/newsletter_templates/ks_multi_process_settings_form"
          content_block.public_name_key = "decidim.newsletter_templates.ks_multi_process.name"

          content_block.images = [
            {
              name: :main_image,
              uploader: "Decidim::NewsletterTemplateImageUploader",
              preview: -> { ActionController::Base.helpers.asset_path("decidim/admin_extended/newsletter-warsaw-image.jpg") }
            }
          ]

          content_block.settings do |settings|
            settings.attribute(
              :title,
              type: :text,
              translated: true,
              preview: -> { I18n.t("decidim.newsletter_templates.ks_multi_process.title_preview") }
            )

            settings.attribute(
              :lead,
              type: :text,
              translated: true,
              preview: -> { I18n.t("decidim.newsletter_templates.ks_multi_process.lead_preview") }
            )
            settings.attribute(
              :introduction,
              type: :text,
              translated: true,
              preview: -> { I18n.t("decidim.newsletter_templates.ks_multi_process.introduction_preview") }
            )
            settings.attribute(
              :body,
              type: :text,
              translated: true,
              preview: -> { I18n.t("decidim.newsletter_templates.ks_multi_process.body_preview") }
            )
            settings.attribute(
              :footer,
              type: :text,
              preview: -> { I18n.t("decidim.newsletter_templates.ks_multi_process.footer_preview") }
            )
          end

          content_block.default!
        end
      end

      routes do
        scope "/admin" do
          resources :departments
          resources :mail_templates, only: [:index, :edit, :update]
          resources :additional_translations, only: [:index, :edit, :update]
          resources :main_menu_items
          resources :statistics
          resources :tags
          resources :banned_words, except: :show
          resources :hero_sections, except: [:new, :create, :destroy]
          resources :contact_info_groups, except: :show
          resources :contact_info_positions, except: :show
          resources :faq_groups, except: :show
          resources :faqs, except: :show
        end
      end
      
      initializer "decidim_admin_extended.append_routes", after: :load_config_initializers do |_app|
        Rails.application.routes.append do
          mount Decidim::AdminExtended::Engine => "/"
        end
      
        Decidim::Surveys::AdminEngine.routes.prepend do
          get "/answers/export", to: "surveys#export", as: :export_survey
        end

        # overwritten routes for users
        # bring back also edit and update to allow edit editorial in admin panel
        Decidim::Admin::Engine.routes.prepend do
          resources :users, controller: "users" do
            member do
              post :resend_invitation
              patch :activate_ad
              patch :deactivate_ad
            end
            collection do
              get :export
            end
          end
        end
      end

      # make decorators available to applications that use this Engine
      config.to_prepare do
        Dir.glob(Decidim::AdminExtended::Engine.root + "app/decorators/**/*_decorator*.rb").each do |c|
          load c
        end
      end

      # add cells views paths
      initializer "decidim_admin_extended.add_cells_view_paths" do
        Cell::ViewModel.view_paths << File.expand_path("#{Decidim::AdminExtended::Engine.root}/app/cells")
      end
    end
  end
end
