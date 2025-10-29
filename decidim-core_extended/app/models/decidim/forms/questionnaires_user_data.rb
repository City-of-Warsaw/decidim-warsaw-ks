# frozen_string_literal: true

module Decidim
  module Forms
    class QuestionnairesUserData < ApplicationRecord
      belongs_to :questionnaire, class_name: "Questionnaire", foreign_key: "decidim_questionnaire_id"

      # for send email purposes only
      def name
        email
      end
    end
  end
end
