# frozen_string_literal: true

module Decidim
  module Repository
    module Admin
      class FileEditForm < FileForm
        mimic :file
      end
    end
  end
end
