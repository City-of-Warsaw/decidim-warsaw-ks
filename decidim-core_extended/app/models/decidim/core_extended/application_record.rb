module Decidim
  module CoreExtended
    class ApplicationRecord < ActiveRecord::Base
      self.abstract_class = true
    end
  end
end
