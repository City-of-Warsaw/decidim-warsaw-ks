# frozen_string_literal: true

module Decidim
  class ScopeSerializer < ActiveModel::Serializer
    type 'district'

    attributes :id, :name, :address

    def name
      object.name["pl"]
    end

    def address
      object.address
    end
  end
end
