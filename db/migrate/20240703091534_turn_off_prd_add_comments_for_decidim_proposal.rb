class TurnOffPrdAddCommentsForDecidimProposal < ActiveRecord::Migration[5.2]
  def change
    # concern about decidim proposal component, with title:
    # {"pl": "Projekt Uchwały"}
    component = Decidim::Component.find_by(id: 70)
    return unless component

    settings = component.settings
    settings.comments_enabled = false
    component.settings = settings
    component.save
  end
end
