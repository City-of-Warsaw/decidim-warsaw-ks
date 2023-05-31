# frozen-string_literal: true

Decidim::Comments::CommentEvent.class_eval do

  def self.included(base)
    base.class_eval do

      # ovewrtitten method
      # expand method
      # added condition for Decidim::CommentsExtended::UnregisteredAuthor
      # added condition for Decidim::CommentsExtended::UnregisteredAuthorPresenter.new(name_param: 'mail')
      # added condition for Decidim::Organization
      def author_presenter
        return unless author

        @author_presenter ||= case author
                              when Decidim::User
                                Decidim::UserPresenter.new(author)
                              when Decidim::UserGroup
                                Decidim::UserGroupPresenter.new(author)
                              when Decidim::CommentsExtended::UnregisteredAuthor
                                Decidim::CommentsExtended::UnregisteredAuthorPresenter.new(name_param: 'mail')
                              when Decidim::Organization
                                Decidim::OfficialAuthorPresenter.new
                              end
      end

      def author_url
        resource_path
      end
    end
  end
end
