# frozen_string_literal: true

Decidim::Forms::Answer.class_eval do
  include Decidim::Traceable
  include Decidim::Loggable
  include Decidim::CustomAi::AnswerEnums

  has_many :answer_versions,
           -> { order(created_at: :desc) },
           class_name: "Decidim::CustomAi::AnswerVersion",
           foreign_key: "answer_id",
           dependent: :destroy

  has_many :answer_tags,
           class_name: "Decidim::CustomAi::AnswerTag",
           foreign_key: :decidim_forms_answers_id,
           dependent: :destroy

  has_many :tags,
           through: :answer_tags,
           class_name: "Decidim::CustomAi::Tag",
           source: :tag

  scope :tag_eq, lambda { |*tags|
    joins(:answer_tags).where("decidim_custom_ai_answer_tags.decidim_custom_ai_tags_id": tags).distinct
  }
  scope :is_complicated_eq, lambda { |*complicated|
    where(ai_is_complicated: complicated)
  }

  scope :is_vulgar_eq, lambda { |*complicated|
    where(ai_is_vulgar: complicated)
  }

  scope :is_incomplete_eq, lambda { |*complicated|
    where(ai_is_incomplete: complicated)
  }

  scope :is_illogical_eq, lambda { |*complicated|
    where(ai_is_illogical: complicated)
  }

  scope :other_grouping_eq, lambda { |*grouping|
    if grouping == 1
      order(similar_group_id: :desc)
    else
      order(:created_at)
    end
  }

  def self.ransackable_scopes(_auth_object = nil)
    [:is_complicated_eq, :other_grouping_eq, :tag_eq, :is_illogical_eq, :is_incomplete_eq, :is_vulgar_eq]
  end

  def self.log_presenter_class_for(_log)
    Decidim::CustomAi::AdminLog::AnswerPresenter
  end
end
