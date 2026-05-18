# frozen_string_literal: true

Decidim::Headers::ContentSecurityPolicy.module_eval do
  private

  # overwritten: turn off CSP from Decidim
  def append_content_security_policy_headers
  end
end