class AddMisingTranslation < ActiveRecord::Migration[7.0]
  def change
    Decidim::AdminExtended::AdditionalTranslation.create(key: "decidim.reports.create.success_create", value: "Utworzyliśmy zgłoszenie. Teraz zweryfikuje je administrator!", locale: "pl")
  end
end
