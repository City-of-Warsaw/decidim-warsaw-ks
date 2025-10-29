# frozen_string_literal: true

Decidim::FilterFormBuilder.class_eval do
  # This method is ONLY FOR EXPERT QUESTIONS COMPONENT in public
  # It generates a section of options in a filter block
  #
  # @param method [Symbol] The method associated to the filter object of the form builder.
  # @param collection [Array, Decidim::CheckBoxesTreeHelper::TreeNode] The collection
  #        used to display the options. It can be an array of options where each options
  #        if represented by an array containing a value and a name or a check_boxes_tree
  #        struct as defined in Decidim::CheckBoxesTreeHelper for more complex situations
  #        which require nested options.
  # @param label_scope [String] The scope used to translate the title of the section.
  # @param id [String] The id of the section. It is also used to get the translation of
  #        the section title.
  # @param options [Hash] Additional options. Except :type, the rest of options are passed
  #        to the partial used to generate the section.
  # @option options [Symbol, String] :type The type of selector to use with the collection.
  #         It can be check_boxes, radio_buttons or check_boxes_tree (used by default when
  #         tree struct is passed. The default selector for arrays is radio_buttons.
  #
  # @return [ActionView::OutputBuffer] the HTML of the generated collection filter.
  def experts_collection_filter(method:, collection:, label_scope:, id:, **options)
    options.merge!(check_boxes_tree_id: check_boxes_tree_id(method))

    @template.render(
      "decidim/expert_questions/user_questions/experts_check_boxes_tree",
      **options.merge(
        method:,
        collection:,
        label_scope:,
        id:,
        form: self
      )
    )
  end
end
