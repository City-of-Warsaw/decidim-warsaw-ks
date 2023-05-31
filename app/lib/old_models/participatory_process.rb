# frozen_string_literal: true

class OldModels::ParticipatoryProcess
  include Virtus.model

  attribute :id, Integer
  attribute :name, String
  attribute :draft, Boolean
  attribute :id, Integer
  attribute :published, DateTime
  attribute :responsible
  attribute :summary
  attribute :targetplace
  attribute :title
  attribute :url

  def initialize(row)
    # ap row[0]
    # ap row["DRAFT"].inspect
    self.draft = row[0]
    # event
    # eventfrom
    # eventto
    self.id = row['ID']
    # language = row['LANGUAGE']
    self.published = row['PUBLISHED']
    self.responsible = row['RESPONSIBLE']
    self.summary = row['SUMMARY']
    self.targetplace = row['TARGETPLACE']
    self.title = row['TITLE']
    self.url = row['URL']
  end

  def importable?
    # Konsultacje społeczne - TAK
    # Konsultacje z NGO - TAK
    # Projekty europejskie - NIE
    # Baza wiedzy - NIE
    # Archiwum - NIE
    # Delta - aktualizacja projektow
    !draft && ['Konsultacje społeczne', 'Konsultacje z NGO', 'Delta'].include?(targetplace)
  end

  # @return values: citizens ngo mix
  def recipients
    case targetplace
    when 'Konsultacje z NGO' then 'ngo'
    when 'Konsultacje społeczne' then 'citizens'
    else nil
    end
  end

  def build_participatory_process(organization)
    process = Decidim::ParticipatoryProcess.new
    process.organization = organization
    update_process_attrs(process)
    # raise "ERROR!" unless process.valid?
    # process.save!
    process
  end

  def update_process_attrs(process)
      process.old_id = id
      process.title = { pl: title }
      process.subtitle = { pl: title }
      process.weight = 0
      process.slug = title.parameterize
      # usuwamy liczby z poczatku sluga
      process.slug = process.slug.gsub('3-', '').gsub('4-', '').gsub('7-', '')
      process.hashtag = nil
      process.description = { pl: title }
      process.short_description = { pl: summary }
      process.hero_image = nil
      process.banner_image = nil
      process.promoted = false
      process.scopes_enabled = false
      process.scope = nil
      process.scope_type_max_depth = nil
      process.private_space = false
      process.developer_group = { pl: "" }
      process.local_area = { pl: "" }
      process.area = nil
      process.target = { pl: "" }
      process.participatory_scope = { pl: "" }
      process.participatory_structure = { pl: "" }
      process.meta_scope = { pl: "" }
      process.start_date = published
      # process.end_date = published + 20.years
      process.published_at = published # publikacja
      process.participatory_process_group = nil
      process.recipients = recipients
  end
end

