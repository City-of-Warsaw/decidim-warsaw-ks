# frozen_string_literal: true

require "rails_helper"

module Decidim
  module Admin
    describe UpdateStaticPage do
      let(:command) { described_class.new(static_page, form) }

      let(:admin) { create(:user, :confirmed, :admin, organization: organization, ad_role: 'decidim_ks_cks_admin', admin: false) }
      let(:participatory_processes) { create(:participatory_processes) }
      let(:gallery) { Decidim::Repository::Gallery.create(name: 'Name') }

      let(:static_page) { Decidim::StaticPage.create(
                                                      title: Decidim::Faker::Localized.localized {generate(:title)}, 
                                                      slug: 'pierwsza',
                                                      gallery_id: gallery.id,
                                                      show_on_help_page: true
                                                    )
                                                  }

      let(:data) do
        {
          title: static_page.title, 
          slug: static_page.slug,
          gallery_id: static_page.gallery_id,
          show_on_help_page: static_page.show_on_help_page
        }
      end

      let!(:form) do
        Decidim::Admin::StaticPageForm.from_params(
          title: data[:title],
          slug: data[:slug],
          gallery_id: data[:gallery_id],
          show_on_help_page: data[:show_on_help_page]
        )
      end

      # TODO: tests failed:
      # Failure/Error: it { expect(static_page.persisted?).to eq(true) }
      # expected: true
      #      got: false

      context "factories & elemental fixtures test" do
        it { expect(static_page.persisted?).to eq(true) }
      end

      # TODO: tests failed:
      # NoMethodError:
      # undefined method `title_[]' for #<Decidim::Admin::StaticPageForm:0x000000010b4472b0>
      # Did you mean?  title_en
      #                title_pl

      context "when slug is nil" do
        it "doesn't update static page" do
          static_page.slug = nil
          expect { command.call }.to broadcast(:invalid)
        end
      end

      # TODO: tests failed:
      # NoMethodError:
      # undefined method `title_[]' for #<Decidim::Admin::StaticPageForm:0x000000010b4472b0>
      # Did you mean?  title_en
      #                title_pl

      context "when valid" do
        it "updates static page" do
          form.show_in_footer = false
          expect { command.call }.to broadcast(:ok)

          expect(static_page.reload.show_on_help_page).to eq(false)
        end
      end
    end
  end
end
