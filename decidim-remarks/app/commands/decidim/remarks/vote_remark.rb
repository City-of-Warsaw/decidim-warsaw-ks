# frozen_string_literal: true

module Decidim
  module Remarks
    # A command with all the business logic to upvote a remark
    class VoteRemark < Decidim::Command
      # Public: Initializes the command.
      #
      # remark - A remark
      # author - A user
      # options - An optional hash of options (default: { weight: 1 })
      #         * weight: The vote's weight. Valid values 1 and -1.
      def initialize(remark, author, options = { weight: 1 })
        @remark = remark
        @author = author
        @weight = options[:weight]
      end

      # Executes the command. Broadcasts these events:
      #
      # - :ok when everything is valid.
      # - :invalid if the vote was not create
      #
      # Returns nothing.
      def call
        case @weight
        when 1
          previous_vote = @remark.up_votes.find_by(user: @author)
          if previous_vote
            previous_vote.destroy!
          else
            @vote = @remark.up_votes.create!(user: @author)
          end
        when -1
          previous_vote = @remark.down_votes.find_by(user: @author)
          if previous_vote
            previous_vote.destroy!
          else
            @vote = @remark.down_votes.create!(user: @author)
          end
        else
          return broadcast(:invalid)
        end

        broadcast(:ok, @remark)
      rescue ActiveRecord::RecordInvalid, ActiveRecord::RecordNotUnique
        broadcast(:invalid)
      end
    end
  end
end
