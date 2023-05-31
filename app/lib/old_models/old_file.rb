# frozen_string_literal: true

class OldModels::OldFile
  include Virtus.model

  attribute :alt, String
  attribute :description, String
  attribute :filename, String
  attribute :responsible, String
  attribute :title, String
  attribute :uploaded, DateTime
  attribute :url, String

  def initialize(row)
    # ap row[0]
    self.alt = row['ALT']
    self.description = row['DESCRIPTION']
    self.filename = row['FILENAME']
    self.responsible = row['RESPONSIBLE']
    self.title = row['TITLE']
    self.url = row['URL']
  end


  # def build_participatory_process(organization)
  #   process = Decidim::ParticipatoryProcess.new
  #   process.organization = organization
  #   update_process_attrs(process)
  #   # raise "ERROR!" unless process.valid?
  #   # process.save!
  #   process
  # end

  # def update_attrs(process)
  #     process.old_id = id
  #
  #     process.target = { pl: "" }
  #     process.participatory_scope = { pl: "" }
  #     process.participatory_structure = { pl: "" }
  #     process.meta_scope = { pl: "" }
  #     process.start_date = published
  #     # process.end_date = published + 20.years
  #     process.published_at = published # publikacja
  #     process.participatory_process_group = nil
  #     process.recipients = recipients
  # end
end

