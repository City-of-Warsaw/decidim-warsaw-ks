# frozen_string_literal: true

require "rails_helper"

module Decidim::ExpertQuestions::AdminLog
  describe ExpertPresenter, type: :helper do
    let(:expert) { create :expert }

    context "when action is update" do
      include_examples "present admin log entry" do
        let(:admin_log_resource) { expert }
        let(:action) { "update" }
      end
    end

    context "when action is create" do
      include_examples "present admin log entry" do
        let(:admin_log_resource) { expert }
        let(:action) { "create" }
      end
    end

    context "when action is publish" do
      include_examples "present admin log entry" do
        let(:admin_log_resource) { expert }
        let(:action) { "publish" }
      end
    end
  end
end
