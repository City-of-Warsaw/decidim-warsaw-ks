# frozen_string_literal: true

Decidim::Searchable.class_eval do
  # overwritten method
  # completely rebuild
  # client does not use:
  # użytkowników - Decidim::User
  # grupy użytkowników - Decidim::UserGroup
  # propozycji - Decidim::Proposals::Proposal
  # custom - client does not search FAQ
  # pytania i odpowiedzi - Decidim::AdminExtended::Faq
  # also - set fixed block order according to clients wish
  def self.searchable_resources
    sr = Decidim.resource_manifests.select(&:searchable).inject({}) do |searchable_resources, manifest|
      searchable_resources.update(manifest.model_class_name => manifest.model_class)
    end

    sr.except(
      "Decidim::User",
      "Decidim::UserGroup",
      "Decidim::Proposals::Proposal",
      "Decidim::AdminExtended::Faq"
    )

    sr.slice(
      "Decidim::ParticipatoryProcess",
      "Decidim::Remarks::Remark",
      "Decidim::Comments::Comment",
      "Decidim::ConsultationMap::Remark",
      "Decidim::ExpertQuestions::UserQuestion",
      "Decidim::CustomProposals::CustomProposal",
      "Decidim::Meetings::Meeting",
      "Decidim::Pages::Page",
      "Decidim::ConsultationRequests::ConsultationRequest",
      "Decidim::News::Information",
      "Decidim::StaticPage"
    )
  end

  # overwritten method
  # rebuild order and blocks according to clients wish
  def self.searchable_resources_by_type
    [
      searchable_resources_of_type_participatory_space,
      sr_of_type_remark_map_remark_comment_user_question_custom_proposal,
      sr_of_type_meeting_page_consultation_request_information_help
    ]
  end

  def self.sr_of_type_remark_map_remark_comment_user_question_custom_proposal
    array = %w(
      Decidim::Remarks::Remark
      Decidim::Comments::Comment
      Decidim::ConsultationMap::Remark
      Decidim::ExpertQuestions::UserQuestion
      Decidim::CustomProposals::CustomProposal
    )
    array.index_with { |k| searchable_resources[k] }.compact
  end

  def self.sr_of_type_meeting_page_consultation_request_information_help
    array = %w(
      Decidim::Meetings::Meeting
      Decidim::Pages::Page
      Decidim::ConsultationRequests::ConsultationRequest
      Decidim::News::Information
      Decidim::StaticPage
    )
    array.index_with { |k| searchable_resources[k] }.compact
  end
end
