# frozen_string_literal: true

module Decidim
  module CoreExtended
    class Engine < ::Rails::Engine
      isolate_namespace Decidim::CoreExtended

      routes do
        post "email_follows", to: "email_follows#create"
        get "faqs", to: "faqs#index"
        get "/cookies/accept", to: "cookie_policy#accept", as: :accept_cookies
      end

      initializer "decidim.menu" do
        Decidim.menu :menu do |menu|
          menu.add_item :faqs,
                        I18n.t("menu.faq", scope: "decidim"),
                        decidim_core_extended.faqs_path,
                        position: 7,
                        active: :inclusive
        end
      end

      initializer "decidim_core_extended.prepend_routes", after: :load_config_initializers do |_app|
        Decidim::Core::Engine.routes.prepend do
          get "account/my_follow", controller: "account", action: "my_follow"
          get "account/my_comments", controller: "account", action: "my_comments"
        end
      end

      initializer "decidim_core_extended.register_icons" do
        Decidim.icons.register(name: "ai-generate", icon: "ai-generate", category: "system", description: "", engine: :admin)
        Decidim.icons.register(name: "overline", icon: "overline", category: "system", description: "", engine: :admin)
        Decidim.icons.register(name: "download-2-line", icon: "download-2-line", category: "system", description: "", engine: :core)
      end

      initializer "decidim_surveys.prepend_routes", after: :load_config_initializers do |_app|
        Decidim::Surveys::Engine.routes.prepend do
          get "response/:uuid", as: :show_survey_responses, controller: "surveys", action: "show"
        end
      end

      initializer "decidim.user_menu" do
        Decidim.menu :user_menu do |menu|
          # overwritten - remove authorizations
          menu.remove_item :authorizations
          # overwritten - remove notifications_settings
          menu.remove_item :notifications_settings
          menu.add_item :my_follow,
                        "Obserwowane", # here we not use it as sys_name for MainMenuItem
                        account_my_follow_path,
                        position: 1,
                        active: is_active_link?(account_my_follow_path, :inclusive)

          menu.add_item :my_comments,
                        "Moje opinie", # here we not use it as sys_name for MainMenuItem
                        account_my_comments_path,
                        position: 1.01,
                        active: is_active_link?(account_my_comments_path, :inclusive)
        end
      end

      Decidim.menu :home_content_block_menu do |menu|
        menu.add_item :home,
                      I18n.t("menu.home", scope: "decidim"),
                      decidim.root_path,
                      position: 1,
                      active: :inclusive
        menu.add_item :pages,
                      "Pomoc",
                      decidim.pages_path,
                      position: 2,
                      active: :inclusive
        menu.add_item :faqs,
                      I18n.t("menu.faq", scope: "decidim"),
                      decidim_core_extended.faqs_path,
                      position: 7,
                      active: :inclusive
      end

      initializer "decidim_core_extended.append_routes", after: :load_config_initializers do |_app|
        Rails.application.routes.append do
          mount Decidim::CoreExtended::Engine => "/"
        end
      end

      initializer "decidim_comments.append_routes", after: :load_config_initializers do |_app|
        Decidim::Comments::Engine.routes.append do
          patch "comments/:id/second_step_update", to: "comments#second_step_update", as: :second_step_update_comment
        end
      end

      initializer "decidim.core_extended.register_resources" do
        Decidim.register_resource(:static_page) do |resource|
          resource.model_class_name = "Decidim::StaticPage"
          resource.card = "decidim/pages"
          resource.searchable = true
        end
      end

      # overwritten decidim
      # remove elements from search
      unsearchable_resources_manifest_names = %w(
        assembly
        initiative
        conference
        consultation
        voting
        blogpost
        budget
        project
        debate
      )
      unsearchable_resources_manifest_names.each do |manifest_name|
        resourcable = Decidim.find_resource_manifest(manifest_name)
        resourcable.searchable = false if resourcable
      end

      # make decorators available to applications that use this Engine
      config.to_prepare do
        Dir.glob(Decidim::CoreExtended::Engine.root + 'app/decorators/**/*_decorator*.rb').each do |c|
          load c
        end
      end

      # cells
      initializer "decidim_core_extended.add_cells_view_paths" do
        Cell::ViewModel.view_paths << File.expand_path("#{Decidim::CoreExtended::Engine.root}/app/cells")
        Cell::ViewModel.view_paths << File.expand_path("#{Decidim::CoreExtended::Engine.root}/app/views")
      end

      initializer "decidim.core.homepage_content_blocks", after: :load_config_initializers do |_app|
        hero_cb = Decidim.content_blocks.for(:homepage).detect do |v|
          v.name == :hero
        end

        hero_cb.settings do |settings|
          settings.attribute :addition_to_welcome_text, type: :text, translated: true
          settings.attribute :description, type: :text, editor: true
          settings.attribute :hero_image_action_title, type: :text
          settings.attribute :hero_image_action_url, type: :text
          settings.attribute :hero_image_alt, type: :text
        end

        newsletter_section = Decidim.content_blocks.for(:newsletter_template).detect do |v|
          v.name == :basic_only_text
        end
        newsletter_section.settings do |settings|
          settings.attribute(
            :body,
            type: :text,
            translated: true,
            preview: -> { I18n.t("decidim.newsletter_templates.basic_only_text.body_preview") }
          )
          settings.attribute :footer, type: :text, editor: true
        end

        Decidim.content_blocks.register(:homepage, :meetings_map) do |content_block|
          content_block.cell = "decidim/content_blocks/meetings_map"
          content_block.public_name_key = "decidim.content_blocks.meetings_map.name"
          content_block.settings_form_cell = "decidim/content_blocks/meetings_map_settings_form"
          content_block.default!
          content_block.settings do |settings|
            # radio buttons - select specific five meetings or all current & upcoming
            settings.attribute :meetings_selection, type: :text
            # five meetings - each chosen separately
            settings.attribute :first_meeting, type: :integer
            settings.attribute :second_meeting, type: :integer
            settings.attribute :third_meeting, type: :integer
            settings.attribute :fourth_meeting, type: :integer
            settings.attribute :fifth_meeting, type: :integer
          end
        end

        Decidim.content_blocks.register(:homepage, :register_user) do |content_block|
          content_block.cell = "decidim/content_blocks/register_user"
          content_block.public_name_key = "decidim.content_blocks.register_user.name"
          content_block.settings_form_cell = "decidim/content_blocks/register_user_settings_form"

          content_block.settings do |settings|
            settings.attribute :header, type: :text
            settings.attribute :description, type: :text, editor: true
            settings.attribute :action_title, type: :text
          end

          # It does not affect the activity status of this content block
          content_block.default!
        end

        Decidim.content_blocks.register(:homepage, :two_part_block_info) do |content_block|
          content_block.cell = "decidim/content_blocks/two_part_block_info"
          content_block.public_name_key = "decidim.content_blocks.two_part_block_info.name"
          content_block.settings_form_cell = "decidim/content_blocks/two_part_block_info_settings_form"

          content_block.settings do |settings|
            settings.attribute :left_title, type: :text
            settings.attribute :left_description, type: :text
            settings.attribute :left_block_url, type: :text

            settings.attribute :right_title, type: :text
            settings.attribute :right_description, type: :text
            settings.attribute :right_block_url, type: :text
          end

          # It does not affect the activity status of this content block
          content_block.default!
        end
      end
    end
  end
end
