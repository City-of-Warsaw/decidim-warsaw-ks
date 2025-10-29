# frozen_string_literal: true

module Decidim
  # This class deals with uploading hero images to ParticipatoryProcesses.
  class TempHeroImageUploader < HeroImageUploader
    # OVERWRITTEN DECIDIM METHOD
    # remove organization validation
    def validate_inside_organization
    end
  end
end
