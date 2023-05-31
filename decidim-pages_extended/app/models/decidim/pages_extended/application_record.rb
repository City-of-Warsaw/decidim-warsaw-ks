module Decidim
  module PagesExtended
    class ApplicationRecord < ActiveRecord::Base
      self.abstract_class = true
    end
  end
end
