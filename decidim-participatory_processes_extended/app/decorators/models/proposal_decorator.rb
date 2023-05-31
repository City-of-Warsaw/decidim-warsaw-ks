# frozen_string_literal: true

Decidim::Proposals::Proposal.class_eval do
  has_many :email_follows,
           as: :followable,
           foreign_key: "decidim_followable_id",
           foreign_type: "decidim_followable_type",
           class_name: "Decidim::CoreExtended::EmailFollow"
end
