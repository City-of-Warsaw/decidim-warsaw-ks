# frozen_string_literal: true

Decidim::Comments::VoteComment.class_eval do
  # overwritten method
  # do not notify comment author if vote/like - do not generate decidim event
  def call
    case @weight
    when 1
      previous_vote = @comment.up_votes.find_by(author: @author)
      if previous_vote
        previous_vote.destroy!
      else
        @vote = @comment.up_votes.create!(author: @author)
      end
    when -1
      previous_vote = @comment.down_votes.find_by(author: @author)
      if previous_vote
        previous_vote.destroy!
      else
        @vote = @comment.down_votes.create!(author: @author)
      end
    else
      return broadcast(:invalid)
    end

    broadcast(:ok, @comment)
  rescue ActiveRecord::RecordInvalid, ActiveRecord::RecordNotUnique
    broadcast(:invalid)
  end
end
