class ChangeMainManuItemsNames < ActiveRecord::Migration[7.0]
  def up
    [
      ['Strona główna', 'home'],
      ['Aktualności', 'news'],
      ['Pomoc', 'pages'],
      ['Procesy', 'participatory_processes'],
      ['Wnioski o konsultacje', 'consultation_requests'],
      ['Strefa koordynatora konsultacji', 'info_articles'],
      ['Pytania i odpowiedzi', 'faqs']
    ].each do |el|
      old_name = el[0]
      sys_name = el[1]
      item = Decidim::AdminExtended::MainMenuItem.find_by sys_name: old_name
      if item
        item.update_column(:sys_name, sys_name)
      else
        puts "Brakuje pozycji: #{old_name} "
      end
    end
  end

  def down
  end
end
