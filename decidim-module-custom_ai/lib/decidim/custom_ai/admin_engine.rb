# frozen_string_literal: true

module Decidim
  module CustomAi
    # This is the engine that runs on the public interface of `CustomAi`.
    class AdminEngine < ::Rails::Engine
      isolate_namespace Decidim::CustomAi::Admin

      paths["db/migrate"] = nil
      paths["lib/tasks"] = nil

      routes do
        scope "/admin/participatory_processes/:participatory_process_slug/components/:component_id/" do
            # access to prompt AI for summary, in component with active module AI
            get "generate_summary",
                to: "/decidim/custom_ai/admin/summaries#generate_summary",
                as: :ai_generate_summary
            
            post "ai_api", to: "/decidim/custom_ai/admin/api#api", as: :ai_api

            resources :answers, only: [:index, :show, :edit, :update] do
              get "init_import_ai_decisions_form",
                  to: "/decidim/custom_ai/admin/answers#init_import_ai_decisions_form",
                  as: :init_import_ai_decisions_form, on: :collection
              patch "import_ai_decisions",
                    to: "/decidim/custom_ai/admin/answers#import_ai_decisions",
                    as: :import_ai_decisions, on: :collection
              get "export_answers",
                  to: "/decidim/custom_ai/admin/answers#export",
                  as: :export_answers, on: :collection
              get "update_grouping",
                  to: "/decidim/custom_ai/admin/answers#update_grouping",
                  as: :update_grouping, on: :collection
              patch "mark_as_accepted",
                    to: "/decidim/custom_ai/admin/answers#mark_as_accepted",
                    as: :mark_as_accepted, on: :collection
              get "init_ai_decision_form",
                  to: "/decidim/custom_ai/admin/answers#init_ai_decision_form",
                  as: :init_ai_decision_form, on: :collection
              get "regenerate_pending_answers_from_ai",
                  to: "/decidim/custom_ai/admin/answers#regenerate_pending_answers_from_ai",
                  as: :regenerate_pending_answers_from_ai, on: :collection
              patch "update_ai_decision",
                    to: "/decidim/custom_ai/admin/answers#update_ai_decision",
                    as: :update_ai_decision, on: :collection
            end

            resources :tags do
              get "generate_tags",
                  to: "/decidim/custom_ai/admin/tags#generate_tags_from_ai",
                  as: :generate_tags_from_ai, on: :collection
              get "regenerate_all_tags",
                  to: "/decidim/custom_ai/admin/tags#regenerate_tags_from_ai",
                  as: :regenerate_tags_from_ai, on: :collection
              delete "destroy_all_of_that_component",
                     to: "/decidim/custom_ai/admin/tags#destroy_all_of_that_component",
                     as: :destroy_all_of_that_component, on: :collection
            end

            resources :files, only: [:index, :new, :create, :destroy] do
              get "new_xlsx_file",
                  to: "/decidim/custom_ai/admin/files#new_xlsx_file",
                  as: :new_xlsx_file ,on: :collection
              post "send_xlsx_file",
                   to: "/decidim/custom_ai/admin/files#send_xlsx_file",
                   as: :send_xlsx_file ,on: :collection
            end
      end
      end

      def load_seed
        nil
      end

      initializer "decidim_custom_ai.append_routes", after: :load_config_initializers do |_app|
        Rails.application.routes.append do
          mount Decidim::CustomAi::AdminEngine => '/'
        end
      end

    end
  end
end
