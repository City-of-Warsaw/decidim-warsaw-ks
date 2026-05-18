# frozen_string_literal: true

module Decidim
  module CustomAi
    module AnswerEnums
      extend ActiveSupport::Concern

      included do
        # rozstrzygnięcie
        # istniejące zapisy strategii uwzględniają treść uwagi - 0
        # uwzględniliśmy - 1
        # uwzględnilismy częściowo - 2
        # nie uwzględniliśmy - 3
        # nie dotyczy - 4
        enum :ai_decision_status, {
          included_in_strategy: 0,
          considered: 1,
          partially_considered: 2,
          not_considered: 3,
          not_applicable: 4,
          for_further_analysis: 5
        }, prefix: true

        # status uzasadnienia
        # do ustalenia - 0
        # wersja robocza - 1
        # do weryfikacji - 2
        # zaakceptowane - 3
        enum :status, {
          pending: 0,
          draft: 1,
          for_review: 2,
          accepted: 3
        }
      end
    end
  end
end
