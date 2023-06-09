# frozen_string_literal: true

RSpec.shared_context "when creating a comment by unregistered user" do
  let(:organization) { create(:organization) }
  let(:participatory_process) { create(:participatory_process, organization: organization) }
  let(:component) { create(:component, participatory_space: participatory_process) }
  let(:user) { nil }
  let!(:author) { nil }
  let!(:default_author) { Decidim::CommentsExtended::UnregisteredAuthor.find_by(organization_id: organization.id) }
  let(:dummy_resource) { create :dummy_resource, component: component }
  let(:commentable) { dummy_resource }
  let(:body) { ::Faker::Lorem.paragraph }
  let(:signature) { ::Faker::Lorem.word }
  let(:alignment) { 1 }
  let(:user_group_id) { nil }
  let(:form_params) do
    {
      "comment" => {
        "body" => body,
        "signature" => signature,
        "alignment" => alignment,
        "user_group_id" => user_group_id,
        "commentable" => commentable
      }
    }
  end
  let(:form) do
    Decidim::Comments::CommentForm.from_params(
      form_params
    ).with_context(
      current_organization: organization
    )
  end
  let(:command) { described_class.new(form, author) }
end
