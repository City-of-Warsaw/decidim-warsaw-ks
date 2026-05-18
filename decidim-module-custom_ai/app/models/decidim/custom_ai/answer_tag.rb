# frozen_string_literal: true

module Decidim
  module CustomAi
    # The tag is used to join the Decidim::Forms::Answer with Decidim::CustomAi:Tags
    #
    class AnswerTag < ApplicationRecord
      belongs_to :answer,
                 class_name: "Decidim::Forms::Answer",
                 foreign_key: :decidim_forms_answers_id
      belongs_to :tag,
                 class_name: "Decidim::CustomAi::Tag",
                 foreign_key: :decidim_custom_ai_tags_id
    end
  end
end