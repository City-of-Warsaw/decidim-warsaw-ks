# frozen_string_literal: true

module Decidim::ParticipatoryProcessesExtended
  # Participatory Process Tags are used for many-to-many association between Participatory Process and Tag
  class ProcessScope < ApplicationRecord
    belongs_to :participatory_process,
                class_name: "Decidim::ParticipatoryProcess",
                foreign_key: :decidim_participatory_process_id
    belongs_to :scope,
                class_name: "Decidim::Scope",
                foreign_key: :decidim_scope_id
  end
end
