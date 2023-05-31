module Decidim
  module AdminExtended
    class ApplicationRecord < ActiveRecord::Base
      self.abstract_class = true
    end
  end
end
