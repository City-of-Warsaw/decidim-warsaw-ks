# frozen_string_literal: true

module Decidim
  class AreaSerializer < ActiveModel::Serializer
    type 'category'

    attributes :id, :name

    def name
      object.name["pl"]
    end
  end
end
