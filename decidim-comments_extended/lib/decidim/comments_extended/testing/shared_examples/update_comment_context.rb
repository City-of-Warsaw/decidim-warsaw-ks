# frozen_string_literal: true

RSpec.shared_context "when updating a comment" do
  let(:organization) { create(:organization) }
  let(:participatory_process) { create(:participatory_process, organization: organization) }
  let(:component) { create(:component, participatory_space: participatory_process) }
  let(:user) { nil }
  let!(:author) { nil }
  let!(:default_author) { Decidim::CommentsExtended::UnregisteredAuthor.find_by(organization_id: organization.id) }
  let(:dummy_resource) { create :dummy_resource, component: component }
  let(:commentable) { dummy_resource }
  let!(:comment) { create(:comment, commentable: commentable, author: default_author) }
  let(:updated_comment) { create(:comment, commentable: commentable, author: default_author, email: ::Faker::Internet.email) }
  let(:users_comment) { create(:comment, commentable: commentable) }
  let(:email) { ::Faker::Internet.email }
  let(:age) { Decidim::User::AGE_RANGES[0] }
  let(:gender) { Decidim::User::GENDERS[0] }
  let(:district) { ::Faker::Lorem.word }
  let(:rodo) { true }
  let(:form_params) do
    {
      "email" => email,
      "age" => age,
      "gender" => gender,
      "district" => district,
      'rodo' => rodo,
      "comment" => comment
    }
  end
  let(:form) do
    Decidim::CommentsExtended::CommentUpdateForm.from_params(
      form_params
    ).with_context(
      current_organization: organization
    )
  end
  let(:command) { described_class.new(form) }
end
