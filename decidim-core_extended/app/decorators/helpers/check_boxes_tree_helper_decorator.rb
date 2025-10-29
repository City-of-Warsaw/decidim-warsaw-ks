# frozen_string_literal: true

Decidim::CheckBoxesTreeHelper.module_eval do

  # copied original from decidim, with no changes
  TreeNode = Struct.new(:leaf, :node) do
    def tree_node?
      is_a?(TreeNode)
    end
  end

  # copied original from decidim, with no changes
  TreePoint = Struct.new(:value, :label) do
    def tree_node?
      is_a?(TreeNode)
    end
  end

  # overwritten
  # - removed global_scope element from filter tree
  def filter_global_scopes_values
    scopes = current_organization.scopes.top_level
    scopes_values = scopes.compact.flat_map do |scope|
      TreeNode.new(
        TreePoint.new(scope.id.to_s, translated_attribute(scope.name)),
        scope_children_to_tree(scope, nil)
      )
    end
    filter_tree_from(scopes_values)
  end

end