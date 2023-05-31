# frozen_string_literal: true

module Decidim::CoreExtended
  class ZipCode < ApplicationRecord
    validates :code, presence: true, uniqueness: true
  end
end
