# frozen_string_literal: true

require "obscenity/active_model"

Decidim::Comments::CommentForm.class_eval do
  include Decidim::UserProfilableCollections
  include Decidim::HasUploadValidations

  attribute :signature, String
  attribute :files, [ActionDispatch::Http::UploadedFile]
  attribute :remove_files, Array
  attribute :token, String
  attribute :age, String
  attribute :gender, String
  attribute :district_id, String

  validates :signature,
            length: { maximum: 40 },
            obscenity: { message: :banned_word_in_name },
            if: -> { signature.present? }
  validates :body, obscenity: { message: :banned_word }
  validates :files, passthru: { to: Decidim::Comments::Comment }

  def signature_max_length_form
    40
  end
end
