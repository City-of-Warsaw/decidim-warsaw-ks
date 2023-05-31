# frozen_string_literal: true

module Decidim
  module ExpertQuestions
    module Admin
      # This controller is the abstract class from which all other controllers of
      # this engine inherit.
      #
      # Note that it inherits from `Decidim::Admin::Components::BaseController`, which
      # override its layout and provide all kinds of useful methods.
      class ApplicationController < Decidim::Admin::Components::BaseController
        helper Decidim::ApplicationHelper
        helper_method :experts, :expert

        def experts
          @experts ||= Expert.where(component: current_component).order(start_time: :desc).page(params[:page]).per(15)
        end

        def expert
          @expert ||= experts.find(params[:id]) if params[:id]
        end
      end
    end
  end
end
