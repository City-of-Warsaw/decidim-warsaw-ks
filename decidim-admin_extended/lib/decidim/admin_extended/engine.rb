module Decidim
  module AdminExtended
    class Engine < ::Rails::Engine
      isolate_namespace Decidim::AdminExtended

      initializer "decidim.user_menu" do
        Decidim.menu :admin_settings_menu do |menu|
          menu.item I18n.t("menu.customizing_menu", scope: "decidim.admin"),
                    decidim_admin_extended.main_menu_items_path,
                    position: 1.15,
                    if: allowed_to?(:update, :organization, organization: current_organization),
                    active: is_active_link?(decidim_admin_extended.main_menu_items_path)
          menu.item I18n.t("menu.tags", scope: "decidim.admin"),
                    decidim_admin_extended.tags_path,
                    position: 1.45,
                    if: allowed_to?(:update, :organization, organization: current_organization),
                    active: is_active_link?(decidim_admin_extended.tags_path)
          menu.item I18n.t("menu.departments", scope: "decidim.admin"),
                    decidim_admin_extended.departments_path,
                    position: 1.45,
                    if: allowed_to?(:update, :organization, organization: current_organization),
                    active: is_active_link?(decidim_admin_extended.departments_path)
          menu.item I18n.t("menu.mail_templates", scope: "decidim.admin"),
                    decidim_admin_extended.mail_templates_path,
                    position: 1.46,
                    if: allowed_to?(:update, :organization, organization: current_organization),
                    active: is_active_link?(decidim_admin_extended.mail_templates_path)
          menu.item I18n.t("menu.statistics", scope: "decidim.admin"),
                    decidim_admin_extended.statistics_path,
                    position: 1.65,
                    if: allowed_to?(:update, :organization, organization: current_organization),
                    active: is_active_link?(decidim_admin_extended.statistics_path)
          menu.item I18n.t("menu.banned_words", scope: "decidim.admin"),
                    decidim_admin_extended.banned_words_path,
                    position: 1.75,
                    if: current_user.ad_admin?,
                    active: is_active_link?(decidim_admin_extended.banned_words_path)
          menu.item I18n.t("menu.hero_sections", scope: "decidim.admin"),
                    decidim_admin_extended.hero_sections_path,
                    position: 1.85,
                    if: current_user.ad_admin?,
                    active: is_active_link?(decidim_admin_extended.hero_sections_path)
        end
      end

      initializer "decidim.core.newsletter_templates" do
        Decidim.content_blocks.register(:newsletter_template, :ks_custom) do |content_block|
          content_block.cell = "decidim/admin_extended/newsletter_templates/ks_custom"
          content_block.settings_form_cell = "decidim/admin_extended/newsletter_templates/ks_custom_settings_form"
          content_block.public_name_key = "decidim.admin_extended.newsletter_templates.ks_custom.name"

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
          end

          content_block.default!
        end
      end

      initializer "decidim_admin_extended.assets.precompile" do |app|
        app.config.assets.precompile += %w(decidim/admin_extended/newsletter-warsaw-image.jpg)
      end

      routes do
        scope "/admin" do
          resources :departments
          resources :mail_templates, only: [:index, :edit, :update]
          resources :main_menu_items
          resources :statistics
          resources :tags
          resources :banned_words, except: :show
          resources :hero_sections, except: [:new, :create, :destroy]
          resources :contact_info_groups, except: [:index, :show]
          resources :contact_info_positions, except: :show
        end
      end

      initializer "decidim_admin_extended.append_routes", after: :load_config_initializers do |_app|
        Rails.application.routes.append do
          mount Decidim::AdminExtended::Engine => "/"
        end
      end

      # decorators
      config.autoload_paths << File.join(
        Decidim::AdminExtended::Engine.root, "app", "decorators", "{**}"
      )

      # make decorators available to applications that use this Engine
      config.to_prepare do
        Dir.glob(Decidim::AdminExtended::Engine.root + "app/decorators/**/*_decorator*.rb").each do |c|
          require_dependency(c)
        end
      end

      # add cells views paths
      initializer "decidim_admin_extended.add_cells_view_paths" do
        Cell::ViewModel.view_paths << File.expand_path("#{Decidim::AdminExtended::Engine.root}/app/cells")
      end
    end
  end
end
