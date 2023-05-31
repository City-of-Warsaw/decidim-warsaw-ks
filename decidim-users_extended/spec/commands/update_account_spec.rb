# frozen_string_literal: true

require "rails_helper"

module Decidim
  describe UpdateAccount do
    let(:command) { described_class.new(user, form) }
    let(:user) { create(:user, :confirmed) }
    let(:scope) { create(:scope, organization: user.organization)}
    let(:scope_two) { create(:scope, organization: user.organization)}
    let(:data) do
      {
        name: user.name,
        nickname: user.nickname,
        email: user.email,
        password: nil,
        password_confirmation: nil,
        avatar: nil,
        remove_avatar: nil,
        personal_url: "https://example.org",
        about: "This is a description of me",
        # custom
        gender: 'male',
        birth_year: 1990,
        district: scope,
        zip_code: '23-345'
      }
    end

    let(:form) do
      Decidim::AccountForm.from_params(
        name: data[:name],
        nickname: data[:nickname],
        email: data[:email],
        password: data[:password],
        password_confirmation: data[:password_confirmation],
        avatar: data[:avatar],
        remove_avatar: data[:remove_avatar],
        personal_url: data[:personal_url],
        about: data[:about],
        # custom
        gender: data[:gender],
        birth_year: data[:birth_year],
        district: data[:district],
        zip_code: data[:zip_code]
      ).with_context(current_organization: user.organization, current_user: user)
    end

    context "when invalid" do
      it "doesn't update birth year" do
        form.birth_year = Date.current.year
        old_birth_year = user.birth_year
        expect { command.call }.to broadcast(:invalid)
        expect(user.reload.birth_year).to eq(old_birth_year)
      end
    end

    context "when valid" do
      it "updates the users's birth year" do
        form.birth_year = 1980
        expect { command.call }.to broadcast(:ok)
        expect(user.reload.birth_year).to eq(1980)
      end

      it "updates the users's gender" do
        form.gender = "female"
        expect { command.call }.to broadcast(:ok)
        expect(user.reload.gender).to eq("female")
      end

      it "updates the users's district" do
        form.district = scope_two
        expect { command.call }.to broadcast(:ok)
        expect(user.reload.district).to eq(scope_two)
      end

      it "updates the users's zip code" do
        form.zip_code = "00-159"
        expect { command.call }.to broadcast(:ok)
        expect(user.reload.zip_code).to eq("00-159")
      end
    end
  end
end
