# frozen_string_literal: true
# This file is located at `config/assets.rb` of your module.

# Define the base path of your module. Please note that `Rails.root` may not be
# used because we are not inside the Rails environment when this file is loaded.
base_path = File.expand_path("..", __dir__)

Decidim::Webpacker.register_path("#{base_path}/app/packs")
Decidim::Webpacker.register_entrypoints(
  area_polygon_map: "#{base_path}/app/packs/entrypoints/area-polygon-map.js",
  jsbarcode_code128_min: "#{base_path}/app/packs/entrypoints/jsbarcode.code128.min.js",
  area_map: "#{base_path}/app/packs/entrypoints/area-map.js",
  polygon_map: "#{base_path}/app/packs/entrypoints/polygon-map.js",
  geojson_area_map: "#{base_path}/app/packs/entrypoints/geojson-area-map.js",
  knowledge_base: "#{base_path}/app/packs/entrypoints/knowledge_base.js",
  participatory_space: "#{base_path}/app/packs/entrypoints/participatory_space.js",
  geojson_map_admin_study_notes_index: "#{base_path}/app/packs/entrypoints/geojson-map.admin-study-notes-index.js",
  geojson_map_admin: "#{base_path}/app/packs/entrypoints/geojson-map.admin.js",
  leaflet_draw_mod_cs: "#{base_path}/app/packs/entrypoints/leaflet.draw.modCS.js",
  geojson_map: "#{base_path}/app/packs/entrypoints/geojson-map.js",
  autocomplete: "#{base_path}/app/packs/entrypoints/autocomplete.js",
  proposal: "#{base_path}/app/packs/entrypoints/proposal.js",
  meetings_map: "#{base_path}/app/packs/entrypoints/meetings-map.js",
  locations_map: "#{base_path}/app/packs/entrypoints/locations-map.js",
  admin_custom: "#{base_path}/app/packs/entrypoints/admin_custom.js",
  meeting_detail: "#{base_path}/app/packs/entrypoints/meeting-detail.js",
  answer_question: "#{base_path}/app/packs/entrypoints/answer_question.js",
  comments: "#{base_path}/app/packs/entrypoints/comments.js",
  remarks: "#{base_path}/app/packs/entrypoints/remarks.js",
  address_search: "#{base_path}/app/packs/entrypoints/address-search.js",
  admin_custom_css: "#{base_path}/app/packs/entrypoints/admin_custom_css.css",
  attachments_expanding: "#{base_path}/app/packs/entrypoints/attachments-expanding.js",
  share_modal: "#{base_path}/app/packs/entrypoints/share-modal.js",
  multifile_attachments: "#{base_path}/app/packs/entrypoints/multifile-attachments.js",
  general_plan_requests: "#{base_path}/app/packs/entrypoints/general_plan_requests.js",
  study_notes: "#{base_path}/app/packs/entrypoints/study_notes.js",
  admin_study_notes: "#{base_path}/app/packs/entrypoints/admin_study_notes.js"
)

# If you want to import some extra SCSS files in the Decidim main SCSS file
# without adding any extra stylesheet inclusion tags, you can use the following
# method to register the stylesheet import for the main application. This would
# include an SCSS file at `app/packs/stylesheets/your_app_extensions.scss` into
# the Decidim's main SCSS file.
# Decidim::Webpacker.register_stylesheet_import("stylesheets/your_app_extensions")

# If you want to do the same but include the SCSS file for the admin panel's
# main SCSS file, you can use the following method.
# Decidim::Webpacker.register_stylesheet_import("stylesheets/your_app_admin_extensions", group: :admin)
