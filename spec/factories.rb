# frozen_string_literal: true

### factories
# require "decidim/faker/localized"
require "decidim/users_extended/test/factories"
require "decidim/core/test/factories"
require "decidim/admin/test"
require "decidim/assemblies/test/factories"
require "decidim/participatory_processes/test/factories"
require "decidim/comments/test/factories"
require "decidim/meetings/test/factories"

### contexts
require "decidim/comments/test/shared_examples/comment_event"
require "decidim/core/test/shared_examples/admin_log_presenter_examples"
# require "decidim/comments_extended/testing/shared_examples/anonymous_comment_event"
require "decidim/comments_extended/testing/shared_examples/create_comment_by_unregistered_user_context"
require "decidim/comments_extended/testing/shared_examples/update_comment_context"
require "decidim/expert_questions/testing/factories"
require "decidim/remarks/testing/factories"

# copied from decidim-pages - was not available from outside
FactoryBot.define do
  factory :page_component, parent: :component do
    name { Decidim::Components::Namer.new(participatory_space.organization.available_locales, :pages).i18n_name }
    manifest_name { :pages }
    participatory_space { create(:participatory_process, :with_steps, organization: organization) }
  end

  factory :page, class: "Decidim::Pages::Page" do
    body { Decidim::Faker::Localized.wrapped("<p>", "</p>") { generate_localized_title } }
    component { build(:component, manifest_name: "pages") }
  end
end

def age_ranger_arr
  Decidim::User::AGE_RANGES
end

def genders_arr
  Decidim::User::GENDERS
end
