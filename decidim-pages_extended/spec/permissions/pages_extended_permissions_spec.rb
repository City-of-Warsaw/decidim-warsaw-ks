# frozen_string_literal: true

require "rails_helper"

describe Decidim::PagesExtended::Permissions do
  subject { described_class.new(user, permission_action, context).permissions.allowed? }

  let(:admin) { create :user, :admin, organization: organization }
  let(:ad_admin) { create :user, :admin, admin: false, ad_role: 'decidim_ks_cks_admin', organization: organization }
  let(:organization) { create :organization }
  let(:process) { create :participatory_process, organization: organization }
  let(:different_process) { create :participatory_process, organization: organization }
  let(:current_component) { create :component, participatory_space: process, manifest_name: "pages" }
  let(:page) { create :page, component: current_component, title: { pl: 'title' }, body: { pl: 'body' }, published_at: nil }
  let(:context) { {} }
  let(:permission_action) { Decidim::PermissionAction.new(action) }
  let(:coordinator) { create :process_admin, participatory_process: process, ad_role: 'decidim_ks_bem_koordynator' }
  let(:process_admin) { create :process_admin, participatory_process: process }
  let(:outside_coordinator) { create :process_admin, participatory_process: different_process, ad_role: 'decidim_ks_bem_koordynator' }
  let(:outside_process_admin) { create :process_admin, participatory_process: different_process }
  let(:process_collaborator) { create :process_collaborator, participatory_process: process }
  let(:process_moderator) { create :process_moderator, participatory_process: process }
  let(:moderator) { create :process_moderator, participatory_process: process, ad_role: 'decidim_ks_bem_moderator' }
  let(:process_valuator) { create :process_valuator, participatory_process: process }
  let(:expert) { create :user, :admin_terms_accepted, ad_role: 'decidim_ks_bem_ekspert', organization: organization }

  # shared_examples configuration

  shared_examples "allows any action on subject" do |action_subject|
    context "when action subject is #{action_subject}" do
      let(:action) do
        { scope: :admin, action: :foo, subject: action_subject }
      end

      it { is_expected.to eq true }
    end
  end

  shared_examples "access for role" do |access|
    case access
    when true
      it { is_expected.to eq true }
    when :not_set
      it_behaves_like "permission is not set"
    else
      it { is_expected.to eq false }
    end
  end

  shared_examples "access for roles" do |access|
    context "when user is admin" do
      let(:user) { admin }
      it_behaves_like "access for role", access[:admin]
    end

    context "when user is ad_admin" do
      let(:user) { ad_admin }
      it_behaves_like "access for role", access[:ad_admin]
    end

    context "when user is a space admin" do
      let(:user) { process_admin }
      it_behaves_like "access for role", access[:coordinator]
    end

    context "when user is a ad space admin" do
      let(:user) { coordinator }
      it_behaves_like "access for role", access[:ad_coordinator]
    end

    context "when user is a outide_space_admin" do
      let(:user) { outside_process_admin }
      it_behaves_like "access for role", access[:outside_coordinator]
    end

    context "when user is a outide_ad_space_admin" do
      let(:user) { outside_coordinator }
      it_behaves_like "access for role", access[:ad_outside_coordinator]
    end

    context "when user is a space collaborator" do
      let(:user) { process_collaborator }
      it_behaves_like "access for role", access[:collaborator]
    end

    context "when user is a space moderator" do
      let(:user) { process_moderator }
      it_behaves_like "access for role", access[:moderator]
    end

    context "when user is a space ad mmoderator" do
      let(:user) { moderator }
      it_behaves_like "access for role", access[:ad_moderator]
    end

    context "when user is a space valuator" do
      let(:user) { process_valuator }
      it_behaves_like "access for role", access[:valuator]
    end

    context "when user is a space epert" do
      let(:user) { expert }
      it_behaves_like "access for role", access[:expert]
    end
  end

  ### tests

  context "when reading the admin pages component" do
    let(:action) do
      { scope: :admin, action: :read, subject: :pages }
    end

    let(:context) { { current_participatory_space: process, current_component: current_component } }

    it_behaves_like(
      "access for roles",
      admin: false,
      ad_admin: true,
      coordinator: false,
      ad_coordinator: true,
      outside_coordinator: false,
      ad_outside_coordinator: false,
      collaborator: false,
      moderator: false,
      ad_moderator: false,
      valuator: false,
      expert: false
    )
  end

  context "when creating the admin pages component" do
    let(:action) do
      { scope: :admin, action: :create, subject: :pages }
    end

    let(:context) { { current_participatory_space: process, current_component: current_component } }

    it_behaves_like(
      "access for roles",
      admin: false,
      ad_admin: true,
      coordinator: false,
      ad_coordinator: true,
      outside_coordinator: false,
      ad_outside_coordinator: false,
      collaborator: false,
      moderator: false,
      ad_moderator: false,
      valuator: false,
      expert: false
    )
  end

  context "when updating the admin pages component" do
    let(:action) do
      { scope: :admin, action: :update, subject: :pages }
    end

    let(:context) { { current_participatory_space: process, current_component: current_component } }

    it_behaves_like(
      "access for roles",
      admin: false,
      ad_admin: true,
      coordinator: false,
      ad_coordinator: true,
      outside_coordinator: false,
      ad_outside_coordinator: false,
      collaborator: false,
      moderator: false,
      ad_moderator: false,
      valuator: false,
      expert: false
    )
  end

  context "when publishing the admin pages component" do
    let(:action) do
      { scope: :admin, action: :publish, subject: :pages }
    end

    let(:context) { { current_participatory_space: process, current_component: current_component } }

    it_behaves_like(
      "access for roles",
      admin: false,
      ad_admin: true,
      coordinator: false,
      ad_coordinator: false,
      outside_coordinator: false,
      ad_outside_coordinator: false,
      collaborator: false,
      moderator: false,
      ad_moderator: false,
      valuator: false,
      expert: false
    )
  end
end
