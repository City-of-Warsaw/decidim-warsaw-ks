class AddDistanceExtension < ActiveRecord::Migration[5.2]
  def change
    add_cube_extension
    add_earthdistance_extension
  end

  def add_cube_extension
    return if extension_enabled?("cube")

    begin
      # required so that test suite works in ci env
      enable_extension "cube"
    rescue StandardError
      raise <<-MSG.squish
        Decidim requires the cube extension to be enabled in your PostgreSQL.
        You can do so by running `CREATE EXTENSION IF NOT EXISTS "cube";` on the current DB as a PostgreSQL
        super user.
      MSG
    end
  end

  def add_earthdistance_extension
    return if extension_enabled?("earthdistance")

    begin
      # required so that test suite works in ci env
      enable_extension "earthdistance"
    rescue StandardError
      raise <<-MSG.squish
        Decidim requires the earthdistance extension to be enabled in your PostgreSQL.
        You can do so by running `CREATE EXTENSION IF NOT EXISTS "earthdistance";` on the current DB as a PostgreSQL
        super user.
      MSG
    end
  end
end
