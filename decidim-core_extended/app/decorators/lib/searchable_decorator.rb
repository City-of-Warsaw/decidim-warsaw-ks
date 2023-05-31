# frozen_string_literal: true

require 'active_support/concern'
require 'decidim/search_resource_fields_mapper'

# Overwritten
# Public: Add new methods for rebuild filters
Decidim::Searchable.class_eval do
  def self.searchable_resources_of_type_remark_request_news
    searchable_resources.select { |r| r.constantize.ancestors.include?(Decidim::HasComponent) }.reject! do |key|
      key == 'Decidim::ConsultationMap::Remark' || key == 'Decidim::Remarks::Remark'
    end.merge(
      searchable_resources.select { |r| r == 'Decidim::ConsultationRequests::ConsultationRequest' },
      searchable_resources.select { |r| r == 'Decidim::News::Information' }
    )
  end

  def self.searchable_resources_of_type_remark_comment_remark_map
    searchable_resources.select do |r|
      %w[Decidim::Remarks::Remark
         Decidim::Comments::Comment
         Decidim::ConsultationMap::Remark].include?(r)
    end
  end


  def self.searchable_resources_of_type_static_page
    searchable_resources.select { |r| r == 'Decidim::StaticPage' }
  end

  def self.searchable_resources_of_type_question
    searchable_resources.select { |r| r == 'Decidim::ExpertQuestions::UserQuestion' }
  end
end
