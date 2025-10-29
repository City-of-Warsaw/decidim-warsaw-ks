# frozen_string_literal: true
# This migration comes from decidim_news (originally 20240924093501)

class AddNextAttrsToInformation < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_news_informations,
               :published,
               :boolean,
               default: false

    add_column :decidim_news_informations,
               :weight,
               :integer,
               default: 0

    add_column :decidim_news_informations,
               :added_on,
               :date
  end
end
