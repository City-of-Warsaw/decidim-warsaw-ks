# frozen_string_literal: true

Decidim::Comments::EditCommentModalFormCell.class_eval do
  # overwritten method-view
  # use our view - allow unregistered user to edit comment
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
  
  # use token from options if given or from cookies
  def token
    options[:edit_token] || cookies_comment_edit_token(model)
  end

  # overwritten method
  # make it nil
  # TODO: PO UKOŃCZONYCH TESTACH KLIENTA V29 rollback - cofnąć to nadpisanie
  def cache_hash
    nil
  end

  # overwritten method
  # add token & use form_object option if given
  def form_object        
    options[:form_object] || Decidim::Comments::CommentForm.new(
      body: comment.translated_body,
      token: comment.token
    )
  end
end
