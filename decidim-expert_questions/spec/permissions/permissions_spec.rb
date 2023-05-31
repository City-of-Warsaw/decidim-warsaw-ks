# frozen_string_literal: true

require "rails_helper"

describe Decidim::ExpertQuestions::Permissions do
  subject { described_class.new(user, permission_action, context).permissions.allowed? }
  let(:organization) { create :organization }
  let(:process) { create :participatory_process, organization: organization }
  let(:different_process) { create :participatory_process, organization: organization }
  let(:current_component) { create :component, participatory_space: process, manifest_name: "expert_questions" }
  let!(:expert) { create :expert, :confirmed, user: ad_expert, component: current_component }
  let(:context) { {} }
  let(:permission_action) { Decidim::PermissionAction.new(action) }
  let(:user_question) { create :user_question, expert: expert }
  let(:answered_user_question) { create :user_question, :answered, expert: expert }
  let(:expert_answer) { answered_user_question.expert_answer }

  # users
  let(:ad_admin) { create :user, :admin, admin: false, ad_role: 'decidim_ks_cks_admin', organization: organization }
  let(:admin) { create :user, :admin, organization: organization }
  let(:ad_coordinator) { create :process_admin, :admin_terms_accepted, participatory_process: process, ad_role: 'decidim_ks_bem_koordynator' }
  let(:coordinator) { create :process_admin, :admin_terms_accepted, participatory_process: process }
  let(:outside_ad_coordinator) { create :process_admin, :admin_terms_accepted, participatory_process: different_process, ad_role: 'decidim_ks_bem_koordynator' }
  let(:outside_coordinator) { create :process_admin, :admin_terms_accepted, participatory_process: different_process }
  let(:process_collaborator) { create :process_collaborator, :admin_terms_accepted, participatory_process: process }
  let(:ad_moderator) { create :process_moderator, :admin_terms_accepted, participatory_process: process, ad_role: 'decidim_ks_bem_moderator' }
  let(:moderator) { create :process_moderator, :admin_terms_accepted, participatory_process: process }
  let(:process_valuator) { create :process_valuator, :admin_terms_accepted, participatory_process: process }
  let(:ad_expert) { create :expert_user, :confirmed, organization: organization }
  let(:ad_expert_unasigned) { create :expert_user, :confirmed, organization: organization }
  let(:outside_ad_expert) { create :expert_user, :confirmed }

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

    context "when user is a coordinator" do
      let(:user) { coordinator }
      it_behaves_like "access for role", access[:coordinator]
    end

    context "when user is a ad coordinator" do
      let(:user) { ad_coordinator }
      it_behaves_like "access for role", access[:ad_coordinator]
    end

    context "when user is a outide_coordinator" do
      let(:user) { outside_coordinator }
      it_behaves_like "access for role", access[:outside_coordinator]
    end

    context "when user is a ooutside_ad_coordinator" do
      let(:user) { outside_ad_coordinator }
      it_behaves_like "access for role", access[:outside_ad_coordinator]
    end

    context "when user is a space collaborator" do
      let(:user) { process_collaborator }
      it_behaves_like "access for role", access[:process_collaborator]
    end

    context "when user is a space moderator" do
      let(:user) { moderator }
      it_behaves_like "access for role", access[:moderator]
    end

    context "when user is a space ad mmoderator" do
      let(:user) { ad_moderator }
      it_behaves_like "access for role", access[:ad_moderator]
    end

    context "when user is a space valuator" do
      let(:user) { process_valuator }
      it_behaves_like "access for role", access[:valuator]
    end

    context "when user is a space ad_expert" do
      let(:user) { ad_expert }
      it_behaves_like "access for role", access[:ad_expert]
    end

    context "when user is a space ad_expert" do
      let(:user) { ad_expert_unasigned }
      it_behaves_like "access for role", access[:ad_expert_unasigned]
    end

    context "when user is a space outside_ad_expert" do
      let(:user) { outside_ad_expert }
      it_behaves_like "access for role", access[:outside_ad_expert]
    end
  end

  ### experts element

  context "when reading the experts list" do
    let(:action) do
      { scope: :admin, action: :read, subject: :expert }
    end
    let(:context) { { current_participatory_space: process, current_component: current_component } }

    it_behaves_like(
      "access for roles",
      ad_admin: true,
      admin: false,
      ad_coordinator: true,
      coordinator: false,
      outside_ad_coordinator: false,
      outside_coordinator: false,
      process_collaborator: false,
      ad_moderator: false,
      moderator: false,
      ad_expert: true,
      ad_expert_unasigned: false,
      outside_ad_expert: false
    )
  end

  context "when creating the expert" do
    let(:action) do
      { scope: :admin, action: :create, subject: :expert }
    end

    let(:context) { { current_participatory_space: process, current_component: current_component } }

    it_behaves_like(
      "access for roles",
      ad_admin: true,
      admin: false,
      ad_coordinator: true,
      coordinator: false,
      outside_ad_coordinator: false,
      outside_coordinator: false,
      process_collaborator: false,
      ad_moderator: false,
      moderator: false,
      ad_expert: false,
      ad_expert_unasigned: false,
      outside_ad_expert: false
    )
  end

  context "when updating experts" do
    let(:action) do
      { scope: :admin, action: :update, subject: :expert }
    end

    let(:context) { { current_participatory_space: process, current_component: current_component, expert: expert } }

    it_behaves_like(
      "access for roles",
      ad_admin: true,
      admin: false,
      ad_coordinator: true,
      coordinator: false,
      outside_ad_coordinator: false,
      outside_coordinator: false,
      process_collaborator: false,
      ad_moderator: false,
      moderator: false,
      ad_expert: false,
      ad_expert_unasigned: false,
      outside_ad_expert: false
    )
  end

  context "when publishing the expert" do
    let(:action) do
      { scope: :admin, action: :publish, subject: :expert }
    end

    let(:context) { { current_participatory_space: process, current_component: current_component, expert: expert } }

    it_behaves_like(
      "access for roles",
      ad_admin: true,
      admin: false,
      ad_coordinator: false,
      coordinator: false,
      outside_ad_coordinator: false,
      outside_coordinator: false,
      process_collaborator: false,
      ad_moderator: false,
      moderator: false,
      ad_expert: false,
      ad_expert_unasigned: false,
      outside_ad_expert: false
    )
  end

  ### questions & answers element

  context "when reading the user_questions list" do
    let(:action) do
      { scope: :admin, action: :read, subject: :user_questions }
    end
    let(:context) { { current_participatory_space: process, current_component: current_component, expert: expert } }

    it_behaves_like(
      "access for roles",
      ad_admin: true,
      admin: false,
      ad_coordinator: true,
      coordinator: false,
      outside_ad_coordinator: false,
      outside_coordinator: false,
      process_collaborator: false,
      ad_moderator: false,
      moderator: false,
      ad_expert: true,
      ad_expert_unasigned: false,
      outside_ad_expert: false
    )
  end

  context "when creating answer for new question" do
    let(:action) do
      { scope: :admin, action: :create, subject: :expert_answer }
    end

    let(:context) { { current_participatory_space: process, current_component: current_component, user_question: user_question } }

    it_behaves_like(
      "access for roles",
      ad_admin: true,
      admin: false,
      ad_coordinator: true,
      coordinator: false,
      outside_ad_coordinator: false,
      outside_coordinator: false,
      process_collaborator: false,
      ad_moderator: false,
      moderator: false,
      ad_expert: true,
      ad_expert_unasigned: false,
      outside_ad_expert: false
    )
  end

  context "when creating answer for answered question" do
    let(:action) do
      { scope: :admin, action: :create, subject: :expert_answer }
    end

    let(:context) { { current_participatory_space: process, current_component: current_component, user_question: answered_user_question } }

    it_behaves_like(
      "access for roles",
      ad_admin: false,
      admin: false,
      ad_coordinator: false,
      coordinator: false,
      outside_ad_coordinator: false,
      outside_coordinator: false,
      process_collaborator: false,
      ad_moderator: false,
      moderator: false,
      ad_expert: false,
      ad_expert_unasigned: false,
      outside_ad_expert: false
    )
  end

  context "when updating the admin experts component" do
    let(:action) do
      { scope: :admin, action: :update, subject: :expert_answer }
    end

    let(:context) { { current_participatory_space: process, current_component: current_component, expert_answer: expert_answer } }

    it_behaves_like(
      "access for roles",
      ad_admin: true,
      admin: false,
      ad_coordinator: true,
      coordinator: false,
      outside_ad_coordinator: false,
      outside_coordinator: false,
      process_collaborator: false,
      ad_moderator: false,
      moderator: false,
      ad_expert: true,
      ad_expert_unasigned: false,
      outside_ad_expert: false
    )
  end

  context "when publishing the admin experts component" do
    let(:action) do
      { scope: :admin, action: :publish, subject: :expert_answer }
    end

    let(:context) { { current_participatory_space: process, current_component: current_component, expert_answer: expert_answer } }

    it_behaves_like(
      "access for roles",
      ad_admin: true,
      admin: false,
      ad_coordinator: false,
      coordinator: false,
      outside_ad_coordinator: false,
      outside_coordinator: false,
      process_collaborator: false,
      ad_moderator: false,
      moderator: false,
      ad_expert: false,
      ad_expert_unasigned: false,
      outside_ad_expert: false
    )
  end
end
