# Be sure to restart your server when you modify this file.

# Version of your assets, change this if you want to expire all your assets.
Rails.application.config.assets.version = '1.0'

# Add additional assets to the asset load path.
# Rails.application.config.assets.paths << Emoji.images_path
# Add Yarn node_modules folder to the asset load path.
Rails.application.config.assets.paths << Rails.root.join('node_modules')

# Precompile additional assets.
# application.js, application.css, and all non-JS/CSS in the app/assets
# folder are already added.
Rails.application.config.assets.precompile += %w(admin_custom.js admin_custom.css
locations-map/locations-map.js polygon-map/polygon-map.js area-map/area-map.js locations-map/meetings-map.js.erb 
geojson-map/geojson-map.js.erb geojson-map/geojson-map.admin.js.erb geojson-map/leaflet.draw.modCS.js jquery.MultiFile.js)
