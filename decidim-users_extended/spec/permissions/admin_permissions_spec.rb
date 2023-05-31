# frozen_string_literal: true

require "rails_helper"

describe Decidim::Admin::Permissions do
  subject { described_class.new(user, permission_action, context).permissions.allowed? }

  let(:admin) { create :user, :admin, organization: organization }
  let(:ad_admin) { create :user, :admin, organization: organization, admin: false, ad_role: 'decidim_ks_cks_admin' }
  let(:organization) { create :organization }
  let(:process) { create :participatory_process, organization: organization }
  let(:other_process) { create :participatory_process, organization: organization }
  let(:component) { create :component, participatory_space: process, organization: organization }
  let(:context) { {} }
  let(:permission_action) { Decidim::PermissionAction.new(action) }
  let(:coordinator) { create :process_admin, participatory_process: process, ad_role: 'decidim_ks_bem_koordynator', admin_terms_accepted_at: Date.current }
  let(:process_admin) { create :process_admin, participatory_process: process, admin_terms_accepted_at: Date.current }
  let(:outside_coordinator) { create :process_admin, ad_role: 'decidim_ks_bem_koordynator', participatory_process: other_process, admin_terms_accepted_at: Date.current }
  let(:outside_process_admin) { create :process_admin, participatory_process: other_process, admin_terms_accepted_at: Date.current }
  let(:process_collaborator) { create :process_collaborator, participatory_process: process, admin_terms_accepted_at: Date.current }
  let(:process_moderator) { create :process_moderator, participatory_process: process, admin_terms_accepted_at: Date.current }
  let(:moderator) { create :process_moderator, participatory_process: process, ad_role: 'decidim_ks_bem_moderator', admin_terms_accepted_at: Date.current }
  let(:process_valuator) { create :process_valuator, participatory_process: process, admin_terms_accepted_at: Date.current }
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

    context "when user is a ad coordinator" do
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

    context "when user is a space expert" do
      let(:user) { expert }
      it_behaves_like "access for role", access[:expert]
    end
  end

  ### tests - for coponents

  context "when reading the components" do
    let(:action) do
      { scope: :admin, action: :read, subject: :component }
    end

    # let(:context) { { process: process, current_component: :component } }
    let(:context) { { process: process } }

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

  context "when creating the components" do
    let(:action) do
      { scope: :admin, action: :create, subject: :component }
    end

    let(:context) { { process: process, current_component: :component } }

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

  context "when updating the components" do
    let(:action) do
      { scope: :admin, action: :update, subject: :component }
    end

    let(:context) { { process: process, current_component: :component } }

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

  context "when publishing the components" do
    let(:action) do
      { scope: :admin, action: :publish, subject: :component }
    end

    let(:context) { { process: process, current_component: :component } }

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

  ## tests for admin_dashboard
  context "when reading the admin dashboard" do
    let(:action) do
      { scope: :admin, action: :read, subject: :admin_dashboard }
    end

    # let(:context) { { process: process, current_component: :component } }
    # let(:context) { { process: process } }

    it_behaves_like(
      "access for roles",
      admin: false,
      ad_admin: true,
      coordinator: false,
      ad_coordinator: true,
      outside_coordinator: false,
      ad_outside_coordinator: true,
      collaborator: false,
      moderator: false,
      ad_moderator: true,
      valuator: false,
      expert: true
    )
  end

  ## tests for logs
  context "when reading the admin dashboard" do
    let(:action) do
      { scope: :admin, action: :read, subject: :admin_log }
    end

    # let(:context) { { process: process, current_component: :component } }
    # let(:context) { { organization: organization } }

    it_behaves_like(
      "access for roles",
      admin: false,
      ad_admin: true,
      coordinator: false,
      ad_coordinator: true,
      outside_coordinator: false,
      ad_outside_coordinator: true,
      collaborator: false,
      moderator: false,
      ad_moderator: true,
      valuator: false,
      expert: true
    )
  end

  ## tests for global moderations
  context "when reading the admin global_moderation" do
    let(:action) do
      { scope: :admin, action: :any, subject: :global_moderation }
    end

    # let(:context) { { process: process, current_component: :component } }
    # let(:context) { { process: process } }

    it_behaves_like(
      "access for roles",
      admin: false,
      ad_admin: true,
      coordinator: false,
      ad_coordinator: true,
      outside_coordinator: false,
      ad_outside_coordinator: true,
      collaborator: false,
      moderator: false,
      ad_moderator: true,
      valuator: false,
      expert: false
    )
  end
end
