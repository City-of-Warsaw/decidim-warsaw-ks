# frozen_string_literal: true

Decidim::FileValidatorHumanizer.class_eval do

  # OVERWRITTEN DECIDIM METHOD
  # changing message text.
  # Changed line was pointed with comment
  def messages
    messages = []

    if (file_size = max_file_size)
      file_size_mb = (((file_size / 1024 / 1024) * 100) / 100).round
      messages << I18n.t(
        "max_file_size",
        megabytes: file_size_mb,
        scope: "decidim.forms.file_validation"
      )
    end

    if (extensions = extension_allowlist)
      messages << I18n.t(
        "allowed_file_extensions",
        extensions: extensions.join(", "), # changed line
        scope: "decidim.forms.file_validation"
      )
    end

    messages
  end
end