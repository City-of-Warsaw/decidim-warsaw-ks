# frozen_string_literal: true

require "wicked_pdf"

# WickedPDF Global Configuration
#
# Use this to set up shared configuration options for your entire application.
# Any of the configuration options shown here can also be applied to single
# models by passing arguments to the `render :pdf` call.
#
# To learn more, check out the README:
#
# https://github.com/mileszs/wicked_pdf/blob/master/README.md

WickedPdf.configure do |config|
  # wkhtmltopdf must be installed on SUSE from packages and linked to this directory
   unless Rails.env.development?
     config.exe_path =  ENV.fetch("WKHTML_EXE_PATH") { "/usr/bin/wkhtmltopdf" }
   end

  # Needed for wkhtmltopdf 0.12.6+ to use many wicked_pdf asset helpers
  config.enable_local_file_access = true
end
