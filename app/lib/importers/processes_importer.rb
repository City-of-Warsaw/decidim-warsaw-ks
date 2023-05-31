# frozen_string_literal: true

# POLA DO IMPORTU
# ----------------------
# Dzielnica - Zakres (po zmianie tłumaczenia też będzie to "Dzielnica") -> scope_id
# Dla NGO -> Dla NGO -> recipients, RECIPIENTS = %w(citizens ngo mix).freeze
# Temat Tytuł -> title
# Data początkowa - Data rozpoczęcia -> start_dat, end_date
# Data końcowa - Data zakończenia
# Cel -> Opis -> description
# Jak można wziąć udział w konsultacjach  - Opis -> description
# Załączniki (jeśli to możliwe) Załączniki ---

# dodatkowe:
# draft ?
# responsible -> admin
# targetplace -> Tylko konsultacje (a Projekty europejskie, Projekty europejskie)

# dodatkowe wymagane pola:
# ----------------------
# short_description -> wrzucic tam title
# slug - wymagany - wygenerowac
# area - kategoria -

# Pliki maja do 140 MB wielkosci, wiec taki limit musi byc na serwerze dla importu

class Importers::ProcessesImporter < Importers::BaseImporter

  attr_accessor :error_files
  attr_accessor :errors
  attr_accessor :old_processes
  attr_accessor :migration_root, :processes_dir

  def initialize(processes_dir = 'konsultacje')
    self.old_processes = []
    self.errors = []
    self.error_files = []
    self.migration_root = Rails.env.development? ? 'files_to_migrate' : '/var/www/decidim/shared/files_to_migrate'
    self.processes_dir = processes_dir
  end

  # Importers::ProcessesImporter.new('konsultacje').call
  def call
    read_data_from_file
    generate_old_processes
    create_participatory_processes
    update_processes_content
    true
  end

  def read_data_from_file
    path = "#{migration_root}/#{processes_dir}/articles.csv"
    read_data_from_csv_file(path)
  end

  def generate_old_processes
    self.old_processes = []
    @data.each do |row|
      old_process = OldModels::ParticipatoryProcess.new(row)

      # skip selected processes IDs by Karolina
      next if [21535, 21459, 21462, 21461, 21469].include?(old_process.id)

      self.old_processes << old_process
    end
    true
  end

  def create_participatory_processes
    counter = 0
    organization = Decidim::Organization.first
    old_processes.each do |old|
      ap "old ID: #{old.id}"
      next unless old.importable? # nie importujemy draftu

      process = old.build_participatory_process(organization)

      # modyfikujemy duplikaty slugow
      process.slug = "#{process.slug}-1" unless process.valid?
      if process.save!
        counter += 1
      else
        self.errors << process
      end
    end
    ap "Zaimportowano: #{counter} / #{old_processes.size}"
    ap "Bledow: #{errors.size}"
    true
  end

  def update_processes_content
    old_processes.each do |old|
      next unless old.importable? # nie importujemy draftu

      process = Decidim::ParticipatoryProcess.find_by old_id: old.id
      if process
        path = "#{migration_root}/#{processes_dir}/#{old.id}/content.txt"
        process.update_column :description, { pl: File.read(path) }
      else
        raise "Missing consultation"
      end
    end
    true
  end

  # aktualizuje uprawnienia do procesow dla adminow
  def update_admin_permissions
    users = Decidim::User.with_ad_role
    Decidim::ParticipatoryProcess.where.not(old_id: nil).each do |process|
      users.each do |ad_user|
        Decidim::ParticipatoryProcessUserRole.create(user: ad_user, participatory_process: process, role: 'admin')
      end
    end
    true
  end

  def process_attachments
    old_processes.each_with_index do |old_process, index|
      ap "old_process #{index}/#{old_processes.size}:"
      ap old_process
      next unless old_process.importable? # nie importujemy draftu

      process = Decidim::ParticipatoryProcess.find_by old_id: old_process.id

      old_files = get_old_files(old_process, 'attachments.csv')
      import_for_collection(old_files, process, 'Załączniki') if old_files

      old_files = get_old_files(old_process, 'documents.csv')
      import_for_collection(old_files, process, 'Dokumenty') if old_files

      old_files = get_old_files(old_process, 'image.csv')
      import_for_collection(old_files, process, "Zdjęcia") if old_files

      old_files = get_old_files(old_process, 'gallery.csv')
      import_for_collection(old_files, process, "Galeria") if old_files
    end
    # links.csv ?
  end

  def fix_missing_attachments
    old_processes.each_with_index do |old_process, index|
      ap "old_process #{index}/#{old_processes.size}:"
      ap old_process
      next unless old_process.importable? # nie importujemy draftu

      process = Decidim::ParticipatoryProcess.find_by old_id: old_process.id

      old_files = get_old_files(old_process, 'attachments.csv')
      fix_for_collection(old_files, process, 'Załączniki') if old_files

      old_files = get_old_files(old_process, 'documents.csv')
      fix_for_collection(old_files, process, 'Dokumenty') if old_files

      old_files = get_old_files(old_process, 'image.csv')
      fix_for_collection(old_files, process, "Zdjęcia") if old_files

      old_files = get_old_files(old_process, 'gallery.csv')
      fix_for_collection(old_files, process, "Galeria") if old_files
    end
    # links.csv ?
  end

  def get_old_files(old_process, filename)
    file_path = "#{migration_root}/#{processes_dir}/#{old_process.id}/#{filename}"
    return unless File.exist? file_path

    file = File.read(file_path)
    rows = CSV.new(file, col_sep: ',', headers: true).read
    old_files = []
    rows.each do |row|
      old_files << OldModels::OldFile.new(row)
    end
    old_files
  end

  def fix_for_collection(old_files, process, collection_name)
    collection = process.attachment_collections.where("name ->>'pl' = ?", collection_name).first
    raise "Brak kolekcji! #{process.id}" unless collection
    if old_files.size == collection.attachments.count
      ap "wszystko ok - pomijam process_id: #{process.id}, old: #{process.old_id}"
      return
    end

    old_files.each do |old_file|
      next if collection.attachments.where(file: old_file.filename).first

      ap "Dogrywam old_process: #{process.id}, file: #{old_file.filename}"
      create_attachment(collection, old_file, process)
    end
  end

  def import_for_collection(old_files, process, collection_name)
    ap "process: #{process.slug}"
    ap "process.old_id: #{process.old_id}"
    ap "collection_name: #{collection_name}"
    # collection = process.attachment_collections.first
    collection = Decidim::AttachmentCollection.create(
      collection_for: process,
      name: { pl: collection_name },
      description: { pl: collection_name }
    )
    old_files.each do |old_file|
      create_attachment(collection, old_file, process)
    end
  end

  def create_attachment(collection, old_file, process)
    attachment_file_path = "#{migration_root}/#{processes_dir}/documents/#{old_file.filename}"
    ap "attachment_file_path: #{attachment_file_path}"
    attachment = collection.attachments.new
    attachment.attached_to = process
    attachment.attachment_collection = collection
    attachment.title = { I18n.locale => old_file.title }
    attachment.description = { I18n.locale => old_file.description }
    attachment.alt = old_file.alt
    attachment.old_url = old_file.url
    File.open(attachment_file_path) do |file|
      attachment.file = file
      if attachment.valid?
        attachment.save!
      else
        self.error_files << { file_type: attachment.file_type, errors: attachment.errors.to_a.join('; '), old_process: process.old_id, old_file: old_file }
        ap attachment.errors.to_a
        ap attachment.content_type
      end
    end
    attachment
  end


  def reset_table
    Decidim::ParticipatoryProcessUserRole.where(
      decidim_participatory_process_id: Decidim::ParticipatoryProcess.where.not(old_id: nil).pluck(:id)
    ).delete_all

    1.tap do
      Decidim::ParticipatoryProcess.where.not(old_id: nil).each do |process|
        process.attachments.destroy_all
        process.attachment_collections.destroy_all
      end
    end

    ActiveRecord::Base.connection.execute('TRUNCATE "public"."decidim_participatory_processes" RESTART IDENTITY CASCADE;')
    # TODO: remove versions
  end

  # -----------------------------------------

  def test
    reload!
    i.reset_table

    i = Importers::ProcessesImporter.new('konsultacje')
    i.read_data_from_file
    i.generate_old_processes
    i.create_participatory_processes
    i.update_processes_content
    # ".date-display-end" => pon, 06/04/2020
    Benchmark.realtime { i.process_attachments } # 2567.5151722840965s
    Benchmark.realtime { i.fix_missing_attachments } # 274


    i = Importers::ProcessesImporter.new('konsultacje_delta')
    i.read_data_from_file
    i.generate_old_processes
    i.create_participatory_processes
    i.update_processes_content
    Benchmark.realtime { i.process_attachments } # 60s
    Benchmark.realtime { i.fix_missing_attachments } #

    # i.error_files

    i.update_admin_permissions

    # TODO: aktualizacja zdjec i zalacznikow w tresci


    # uploader = Decidim::AttachmentUploader.new
    # uploader = MyUploader.new
    # uploader.store!(attachment_file_path)
    # File.open('somewhere') do |f|
    #   u.avatar = f
    # end

    attachment_file_path = "files_to_migrate/konsultacje/documents/formularz_do_zglaszania_uwag_20.doc"
    File.exist? attachment_file_path
    a = Decidim::Attachment.new
    process = Decidim::ParticipatoryProcess.find_by old_id: 21043
    collection = process.attachment_collections.first
    a.attached_to = process
    a.attachment_collection = collection
    a.weight = 0
    # a.file = File.new(attachment_file_path)
    a.file = File.new(attachment_file_path)
    a.url
    a.file_type
    a.content_type

    process = Decidim::ParticipatoryProcess.find_by old_id: old_process.id
    collection = process.attachment_collections.first

    # attachment_file_path = 'files_to_migrate/konsultacje/documents/program_mapa_0.jpg'
    attachment_file_path = "files_to_migrate/konsultacje/documents/trasa-cala-a.png"
    process = Decidim::ParticipatoryProcess.find_by old_id: 19528
    collection = process.attachment_collections.first
    attachment = collection.attachments.new
    attachment.description = { I18n.locale => 'Test' }
    attachment.title = { I18n.locale => 'test' }
    attachment.attached_to = process
    attachment.attachment_collection = collection
    attachment.file = File.new(attachment_file_path)
    # attachment.file = Pathname.new(attachment_file_path).open
    attachment.valid?
    attachment.errors
    # attachment.save!
  end

end