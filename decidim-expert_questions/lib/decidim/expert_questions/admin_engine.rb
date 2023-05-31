# frozen_string_literal: true

module Decidim
  module ExpertQuestions
    # This is the engine that runs on the public interface of `ExpertQuestions`.
    class AdminEngine < ::Rails::Engine
      isolate_namespace Decidim::ExpertQuestions::Admin

      paths["db/migrate"] = nil
      paths["lib/tasks"] = nil

      routes do
        # Add admin engine routes here
        resources :experts do
          resources :user_questions, only: :index do
            get :export, on: :collection
          end
          get :export, on: :collection
          member do
            put :publish
            put :unpublish
          end
        end

        resources :user_questions, only: [] do
          resources :expert_answers, as: :expert_answers do
            member do
              put :publish
              put :unpublish
            end
          end
        end

        root to: "experts#index"
      end

      def load_seed
        nil
      end
    end
  end
end
