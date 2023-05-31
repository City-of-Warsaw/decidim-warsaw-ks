# frozen_string_literal: true

class Importers::BannedWordsImporter < Importers::BaseImporter

  def initialize(path='wulgaryzmy.txt')
    @file_path = "db/files/wulgaryzmy_KS.txt"
  end

  # Importers::BannedWordsImporter.new.call
  def call
    process_file_data
    true
  end

  def process_file_data
    File.readlines(@file_path).each do |line|
      Decidim::AdminExtended::BannedWord.create(name: line.rstrip)
    end
    true
  end

  # Importers::BannedWordsImporter.new.remove_all_data
  def remove_all_data
    reset_table
    reset_index
  end


  private

  def reset_table
    ActiveRecord::Base.connection.execute("TRUNCATE TABLE decidim_admin_extended_banned_words CASCADE;")
  end

  def reset_index
    ActiveRecord::Base.connection.execute("SELECT setval('decidim_admin_extended_banned_words_id_seq', max(id)) FROM decidim_admin_extended_banned_words;")
  end

end