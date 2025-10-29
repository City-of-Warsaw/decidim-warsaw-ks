class AddMissingElementToDecidimAdminExtendedTranslation < ActiveRecord::Migration[7.0]
  def change
    Decidim::AdminExtended::AdditionalTranslation.create(
      key: "decidim.admin_extended.additional_translation.decidim.account.update.success",
      value: "Zaktualizowaliśmy Twoje konto",
      locale: "pl"
    )
  end
end
