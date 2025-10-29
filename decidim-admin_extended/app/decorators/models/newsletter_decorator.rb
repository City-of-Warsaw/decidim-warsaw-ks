# frozen_string_literal: true

Decidim::Newsletter.class_eval do
    def sended_to_type_ngo?
      extended_data["send_to_type_ngo"]
    end

    def sended_to_tags?
      extended_data["send_to_tags"]
    end
end
