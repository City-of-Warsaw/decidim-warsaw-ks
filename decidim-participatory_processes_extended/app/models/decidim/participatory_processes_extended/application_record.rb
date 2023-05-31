module Decidim
  module ParticipatoryProcessesExtended
    class ApplicationRecord < ActiveRecord::Base
      self.abstract_class = true
    end
  end
end
