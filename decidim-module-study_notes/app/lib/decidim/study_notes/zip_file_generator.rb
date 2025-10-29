# frozen_string_literal: true
#
require "zip"

module Decidim
  module StudyNotes
    class ZipFileGenerator

      # Initialize with the directory to zip and the location of the output archive.
      def initialize(input_dir, output_file)
        @input_dir = input_dir
        @output_file = output_file
      end

      # Zip the input directory.
      def write
        dir_entries = Dir.entries(@input_dir) - %w(. ..)

        ::Zip::File.open(@output_file, ::Zip::File::CREATE) do |zip_file|
          write_entries dir_entries, "", zip_file
        end
      end

      private

      # A helper method to make the recursion work.
      def write_entries(entries, path, zip_file)
        entries.each do |e|
          zip_file_path = path == "" ? e : File.join(path, e)
          disk_file_path = File.join(@input_dir, zip_file_path)

          if File.directory?(disk_file_path)
            recursively_deflate_directory(disk_file_path, zip_file, zip_file_path)
          else
            put_into_archive(disk_file_path, zip_file, zip_file_path)
          end
        end
      end

      def recursively_deflate_directory(disk_file_path, zip_file, zip_file_path)
        zip_file.mkdir zip_file_path
        subdir = Dir.entries(disk_file_path) - %w(. ..)
        write_entries(subdir, zip_file_path, zip_file)
      end

      def put_into_archive(disk_file_path, zip_file, zip_file_path)
        zip_file.add(zip_file_path, disk_file_path)
      end
    end
  end
end
