class AddApplicantToTheRequest < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_consultation_requests, :applicant, :string
  end
end
