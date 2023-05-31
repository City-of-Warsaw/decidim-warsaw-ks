# frozen_string_literal: true

require "rails_helper"

module Decidim
  module ParticipatoryProcesses
    module Admin
      describe ParticipatoryProcessesController, type: :controller do
        routes { Decidim::ParticipatoryProcesses::AdminEngine.routes }

        let(:organization) { create(:organization) }
        let(:admin) { create(:user, :confirmed, :admin, organization: organization, ad_role: 'decidim_ks_cks_admin') }
        let(:coordinator) { create(:user, :confirmed, organization: organization, ad_role: 'decidim_ks_bem_koordynator') }
        let(:area) { create(:area, organization: organization) }
        let(:fb_url) { Faker::Internet.url(host: 'facebook', scheme: 'https') }
        let(:recipients) { 'ngo' }
        let(:fb_url_two) { Faker::Internet.url(host: 'facebook', scheme: 'http') }
        let(:recipients_two) { 'mix' }

        let(:new_process_params) do
          {
            participatory_process: {
              organization: organization,
              title_pl: "Process title",
              title_en: "Process title",
              subtitle_pl: "Process subtitle",
              subtitle_en: "Process subtitle",
              weight: 0,
              slug: "new-process",
              hashtag: "hash",
              short_description_pl: "<p>Lorem ipsum dolor sit amet, consectetur adipiscing elit. Maecenas maximus vehicula nisl ac maximus.</p>",
              short_description_en: "",
              description_pl: "<p>Lorem ipsum dolor sit amet, consectetur adipiscing elit.</p>",
              description_en: "",
              start_date: Date.current,
              end_date: Date.current + 1.year,
              # hero_image: File.open("spec/assets/avatar.jpg"),
              hero_image: fixture_file_upload('spec/assets/avatar.jpg', 'image/jpeg'),
              # banner_image: File.open("spec/assets/avatar.jpg"),
              banner_image: fixture_file_upload('spec/assets/avatar.jpg', 'image/jpeg'),
              promoted: false,
              scopes_enabled: false,
              area_id: area.id,
              fb_url: fb_url,
              recipients: recipients
            }
          }
        end

        context "when coordinator creates process", versioning: true do
          before do
            request.env["decidim.current_organization"] = organization
            sign_in coordinator
          end

          it "he is assigned as process admin" do
            post(:create, params: new_process_params)
            participatory_process = Decidim::ParticipatoryProcess.all.order('created_at DESC').first
            expect(response).to redirect_to(participatory_process_steps_path(participatory_process))
            expect(flash[:notice]).to be_present
            expect(flash[:alert]).not_to be_present
            user_ids = participatory_process.user_roles('admin').map { |x| x.user.id }
            expect(user_ids.include?(coordinator.id)).to be true
          end

          it 'process is created with custom data' do
            post(:create, params: new_process_params)
            participatory_process = Decidim::ParticipatoryProcess.all.order('created_at DESC').first
            expect(participatory_process.fb_url).to eq(fb_url)
            expect(participatory_process.recipients).to eq(recipients)
          end
        end

        context "when admin updates process", versioning: true do
          before do
            request.env["decidim.current_organization"] = organization
            sign_in admin
          end

          it 'he can uopdate custom data' do
            post(:create, params: new_process_params)
            participatory_process = Decidim::ParticipatoryProcess.all.order('created_at DESC').first

            expect(participatory_process.fb_url).to eq(fb_url)
            expect(participatory_process.recipients).to eq(recipients)
            merged_params = new_process_params[:participatory_process].merge(fb_url: fb_url_two, recipients: recipients_two)

            patch :update, params: { slug: participatory_process.slug, participatory_process: merged_params }
            participatory_process.reload
            expect(participatory_process.fb_url).to eq(fb_url_two)
            expect(participatory_process.recipients).to eq(recipients_two)
          end
        end

        context "when admin creates process", versioning: true do
          before do
            request.env["decidim.current_organization"] = organization
            sign_in admin
          end

          it "he is NOT assigned as process admin" do
            post(:create, params: new_process_params)
            participatory_process = Decidim::ParticipatoryProcess.all.order('created_at DESC').first
            expect(response).to redirect_to(participatory_process_steps_path(participatory_process))
            expect(flash[:notice]).to be_present
            expect(flash[:alert]).not_to be_present
            user_ids = participatory_process.user_roles('admin').map { |x| x.user.id }
            expect(user_ids.include?(admin.id)).to be false
          end
        end
      end
    end
  end
end
