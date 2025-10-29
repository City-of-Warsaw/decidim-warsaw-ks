# frozen_string_literal: true

require 'obscenity/active_model'

module Decidim
  module CustomProposals
    module Admin
      # This class holds a Form to create single custom proposal for process component.
      class CustomProposalForm < Decidim::Form
        mimic :custom_proposal

        attribute :title, String
        attribute :body, String
        attribute :published, Decidim::AttributeObject::TypeMap::Boolean, default: false
        attribute :weight, Integer

        validates :title, :weight, presence: true
        validates :published, inclusion: { in: [true, false] }
      end
    end
  end
end
