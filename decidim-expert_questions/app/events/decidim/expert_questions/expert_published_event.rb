# frozen-string_literal: true

module Decidim::ExpertQuestions
  class ExpertPublishedEvent < Decidim::Events::SimpleEvent
    # Overwritten method, nof used for this event
    def resource_url
      nil
    end

    # Overwritten method, nof used for this event
    def resource_path
      nil
    end
  end
end
