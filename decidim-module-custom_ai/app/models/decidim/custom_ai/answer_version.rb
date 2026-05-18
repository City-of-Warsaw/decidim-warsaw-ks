# frozen_string_literal: true

module Decidim
  module CustomAi
    class AnswerVersion < ApplicationRecord
      include Decidim::CustomAi::AnswerEnums

      belongs_to :answer, class_name: "Decidim::Forms::Answer"
      belongs_to :user, class_name: "Decidim::User", foreign_key: "decidim_user_id", optional: true
    end
  end
end
