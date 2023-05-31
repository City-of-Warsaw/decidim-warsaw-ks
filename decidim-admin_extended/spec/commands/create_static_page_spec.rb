# frozen_string_literal: true

require "rails_helper"

require "decidim/faker/localized"
require "decidim/faker/internet"
require "decidim/dev"

module Decidim
  module Admin
    describe CreateStaticPage do
      let(:command) { described_class.new(form) }

      let(:generate_localized_title) { Decidim::Faker::Localized.localized { generate(:title) }}

      let(:admin) { create(:user, :confirmed, :admin, organization: organization, ad_role: 'decidim_ks_admin', admin: false) }
      let(:participatory_processes) { create(:participatory_processes) }
      let(:gallery) { Decidim::Repository::Gallery.create(name: 'Name') }

      # let(:title) do
      #   { 
      #     en: "Title",
      #     pl: "Tytuł"
      #   }
      # end

      let(:static_page) { Decidim::StaticPage.create(gallery_id: gallery.id, show_on_help_page: true) }
      
      # let(:data) do
      #   {
      #     title: generate_localized_title,
      #     slug: 'slug',
      #     gallery_id: gallery.id,
      #     show_on_help_page: false
      #   }
      # end

      # let!(:form) do
      #   Decidim::Admin::StaticPageForm.from_params(
      #     title: data[:title],
      #     slug: data[:slug],
      #     gallery_id: data[:gallery_id],
      #     show_on_help_page: data[:show_on_help_page]
      #   )
      # end

      let(:form) do
        Decidim::Admin::StaticPageForm.from_model(static_page)
      end

      # TODO: tests failed:
      # Failure/Error: it { expect(static_page.persisted?).to eq(true) }
      # expected: true
      #      got: false
      it { expect(static_page.persisted?).to eq(true) }

      # TODO: tests failed:
      # NoMethodError:
      # undefined method `title_[]' for #<Decidim::Admin::StaticPageForm:0x000000010b4472b0>
      # Did you mean?  title_en
      #                title_pl

      context "when slug is nil" do
        it "doesn't create static page" do
          static_page.slug = nil
          expect { command.call }.to broadcast(:invalid)
          expect { command.call }.not_to change(Decidim::StaticPage, :count).by(1)
        end
      end

      # TODO: tests failed:
      # NoMethodError:
      # undefined method `title_[]' for #<Decidim::Admin::StaticPageForm:0x000000010b4472b0>
      # Did you mean?  title_en
      #                title_pl

      context "when valid" do
        it "creates static page" do
          expect { command.call }.to broadcast(:ok)
          expect { command.call }.to change(Decidim::StaticPage, :count).by(1)

          static_page = Decidim::StaticPage.order(created_at: :desc).first
          static_page.gallery_id = data[:gallery_id]
          static_page.show_on_help_page = data[:show_on_help_page]

          expect(static_page.gallery_id).to eq(data[:gallery_id])
          expect(static_page.show_on_help_page).to eq(data[:show_on_help_page])
        end
      end
    end
  end
end
