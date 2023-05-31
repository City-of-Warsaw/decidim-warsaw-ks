# frozen_string_literal: true

# This validator takes care of ensuring the validated content is
# a URL
UrlValidator.class_eval do

  # overwritten validation method due to changing the content of the fixed string to
  # Polish message
  def validate_each(record, attribute, value)
    record.errors[attribute] << (options[:message] || "musi być prawdiłowym adresem URL") unless url_valid?(value)
  end
end
