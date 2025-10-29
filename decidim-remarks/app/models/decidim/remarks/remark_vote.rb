# frozen_string_literal: true

module Decidim
  module Remarks
    class RemarkVote < ApplicationRecord
      belongs_to :remark, foreign_key: :decidim_remarks_remark_id, class_name: "Decidim::Remarks::Remark"
      belongs_to :user, foreign_key: :decidim_user_id, class_name: "Decidim::User"
    end
  end
end
