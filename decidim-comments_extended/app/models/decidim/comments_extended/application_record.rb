module Decidim
  module CommentsExtended
    class ApplicationRecord < ActiveRecord::Base
      self.abstract_class = true
    end
  end
end
