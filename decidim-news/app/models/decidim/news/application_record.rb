# frozen_string_literal: true

module Decidim
  module News
    class ApplicationRecord < ActiveRecord::Base
      self.abstract_class = true
    end
  end
end
