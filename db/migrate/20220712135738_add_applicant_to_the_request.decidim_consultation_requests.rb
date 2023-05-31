# This migration comes from decidim_consultation_requests (originally 20220712135608)
class AddApplicantToTheRequest < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_consultation_requests, :applicant, :string
  end
end
