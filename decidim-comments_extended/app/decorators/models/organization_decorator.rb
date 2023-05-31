# frozen_string_literal: true

Decidim::Organization.class_eval do
  has_one :unregistered_author,
          class_name: "Decidim::CommentsExtended::UnregisteredAuthor",
          dependent: :destroy

  has_many :departments,
           foreign_key: :organization_id,
           class_name: "Decidim::AdminExtended::Department",
           dependent: :destroy

  has_many :tags,
           foreign_key: :organization_id,
           class_name: "Decidim::AdminExtended::Tag",
           dependent: :destroy

  # used as comments author for non registered users
  after_create :create_unregistered_author

  def create_unregistered_author
    Decidim::CommentsExtended::UnregisteredAuthor.create(organization: self)
  end
end
