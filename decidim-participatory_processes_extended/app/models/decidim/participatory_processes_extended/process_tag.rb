# frozen_string_literal: true

module Decidim::ParticipatoryProcessesExtended
  # Participatory Process Tags are used for many-to-many association between Participatory Process and Tag
  class ProcessTag < ApplicationRecord
    belongs_to :participatory_process,
                class_name: "Decidim::ParticipatoryProcess",
                foreign_key: :decidim_participatory_process_id
    belongs_to :tag,
                class_name: "Decidim::AdminExtended::Tag",
                foreign_key: :decidim_admin_extended_tag_id
  end
end
