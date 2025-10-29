class ChangeNameOfHeroSecition < ActiveRecord::Migration[7.0]
  def up
    Decidim::AdminExtended::HeroSection.find_by(:system_name=>"news").update(:title=>"Informacje")
  end
end
