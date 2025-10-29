class RenameImagesToFilesForDecidimConsultationMapRemark < ActiveRecord::Migration[7.0]
  def change
    ActiveStorage::Attachment.where(record_type: "Decidim::ConsultationMap::Remark").update_all(name: "files")
  end
end
