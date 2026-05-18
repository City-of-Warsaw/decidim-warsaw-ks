# frozen_string_literal: true

Decidim::Comments::CommentFormCell.class_eval do
  # overwritten method
  # use our view
  def show
    render :show_new
  end

  # overwritten method
  # kill caching
  # TODO: PO UKOŃCZONYCH TESTACH KLIENTA V29 rollback - cofnąć to nadpisanie
  def perform_caching?
    false
  end

  private
  
  # overwritten method
  # use form_object option if given
  def form_object        
    options[:form_object] || Decidim::Comments::CommentForm.new(
      commentable_gid: model.to_signed_global_id.to_s,
      alignment: 0
    )
  end 

  # overwritten method
  # removed default limit chars if not component, because news are not component
  # increased default limit
  def comments_max_length
    return component_comments_max_length if model.respond_to?(:component) && component_comments_max_length
    return organization_comments_max_length if organization_comments_max_length

    15_000
  end

  def signature_max_length_cell
    40
  end

  # overwritten method
  # make it nil
  # TODO: PO UKOŃCZONYCH TESTACH KLIENTA V29 rollback - cofnąć to nadpisanie
  def cache_hash
    nil
  end
end
