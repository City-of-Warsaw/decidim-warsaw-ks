# frozen_string_literal: true
require 'csv'

module Importers
  class ImporterError < StandardError; end
  class NoUserImporterError < ImporterError; end
  class NoHistoryUserImporterError < ImporterError; end

  class BaseImporter

    attr_accessor :data, :file_path

    # Public: returns Object - Organization of the Project
    def organization
      @organization ||= Decidim::Organization.first
    end

    def import_root_path
      if Rails.env.development?
        'files_to_migrate/'
      else
        # TODO:
        '/var/www/decidim/migracja/task-list-data/'
      end
    end

    def import_files_path

    end

    def read_data_from_json_file(file_path = @file_path)
      file = File.read(file_path)
      @data = JSON.parse file
      ap "#{@data.size} records loaded"
      true
    end

    def read_data_from_csv_file(file_path = @file_path)
      ap file_path
      file = File.read(file_path)
      csv = CSV.new(file, col_sep: ';', headers: true)
      @data = csv.read
      ap "#{@data.size} records loaded"
      true
    end

    def find_old(old_id)
      read_data_from_file if data.blank?
      d = data.select{ |p| p['id'] == old_id.to_s }
      old_model.new(d.first)
    end

    # Importers::ProjectsImporter.new.test_field('isPaper')
    # Importers::ProjectsImporter.new.test_field('status', 50)
    # Importers::ProjectsImporter.new.test_field('projectLevel', 50)
    def test_field(field_name, limit=nil)
      read_data_from_file
      data = limit ? @data.first(limit) : @data
      data.each_with_index do |d, index|
        # ap "#{index}:"
        ap d[field_name]
      end
      true
    end

    def add_log(item, message=nil, body=nil)
      Decidim::Projects::ImportLog.create(old_id: item.id, resource_type: item.class.to_s, message: message, body: body)
    end

  end

end

