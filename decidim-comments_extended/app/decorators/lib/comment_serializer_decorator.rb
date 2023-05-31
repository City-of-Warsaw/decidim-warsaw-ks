# frozen_string_literal: true

Decidim::Comments::CommentSerializer.class_eval do

  # Overwritten
  # Serializes a comment
  def serialize
    {
      id: resource.id,
      created_at: resource.created_at,
      body: resource.body.values.first,
      locale: resource.body.keys.first,
      author: {
        id: resource.author.id,
        name: resource.author.name
      },
      alignment: resource.alignment,
      depth: resource.depth,
      user_group: {
        id: resource.user_group.try(:id),
        name: resource.user_group.try(:name) || empty_translatable
      },
      commentable_id: resource.decidim_commentable_id,
      commentable_type: resource.decidim_commentable_type,
      root_commentable_url: root_commentable_url,
      gender: author_gender,
      age: author_age,
      district: translated_attribute(author_district)
    }
  end

  def author_age
    if resource.unregistered_author?
      resource.age.present? ? I18n.t("age.#{resource.age}", scope: "decidim.comments") : nil
    else
      if resource.author.birth_year
        Date.current.year - resource.author.birth_year
      end
    end
  end

  def author_district
    if resource.unregistered_author?
      resource.district&.name
    else
      resource.author.district&.name
    end
  end

  def author_gender
    if resource.unregistered_author?
      resource.gender.present? ? I18n.t("gender.#{resource.gender}", scope: "decidim.users") : nil
    else
      resource.author.gender.present? ? I18n.t("gender.#{resource.author.gender}", scope: "decidim.users") : nil
    end
  end
end
