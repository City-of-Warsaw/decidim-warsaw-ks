# frozen_string_literal: true

module Decidim
  module CustomProposals
    class CustomProposalCommentsSerializer < Decidim::Exporters::Serializer
      include Decidim::CoreExtended::UrlHelper
      include Decidim::TranslatableAttributes
      include Decidim::CoreExtended::SerializerExportHelper

      def initialize(resource = nil)
        super(resource)
      end

      # Public: Get the order of columns for serializing a comment.
      # Returns an Array of symbols representing the column order.
      def columns_order
        @columns_order ||= [
          :lp,
          :custom_proposal_weight,
          :custom_proposal_title,
          :signature,
          :body,
          :created_at,
          :email,
          :district,
          :age,
          :gender,
          :url
        ]
      end

      def columns_definition
        @columns_definition ||= {
          lp: {
            name: column_name_translation("lp"),
            size: :auto,
            alignment: :right
          },
          custom_proposal_weight: { name: column_name_translation("custom_proposal_weight"), size: :auto },
          custom_proposal_title: { name: column_name_translation("custom_proposal_title"), size: :auto },
          signature: { name: column_name_translation("signature"), size: :auto },
          body: {
            name: column_name_translation("body"),
            size: :body,
            wrap_text: true
          },
          created_at: { name: column_name_translation("created_at"), size: :auto },
          email: { name: column_name_translation("email"), size: :auto },
          district: { name: column_name_translation("district"), size: :auto },
          age: { name: column_name_translation("age"), size: :auto },
          gender: { name: column_name_translation("gender"), size: :auto },
          url: {
            name: column_name_translation("url"),
            size: :url,
            wrap_text: true,
            hyperlink: true
          }
        }
      end

      # Serializes a collection of comments into an array of hashes suitable for exporting.
      # Each comment is assigned a parent sequential number (`lp`).
      # If a comment has attached files, each file gets its own row with a sub-number
      # (e.g., "1.1", "1.2"), while the parent comment information is duplicated across these rows.
      #
      # @param comments [Array<Decidim::Comments::Comment>] The comments to serialize
      # @return [Array<Hash>] Serialized comment data, one hash per row/file
      def serialize_all(comments)
        rows = []
        parent_lp = 0

        comments.each do |comment|
          parent_lp += 1
          urls = links_to_files_array(comment.files, organization: comment.organization)

          if urls.empty?
            rows << comment_attrs(comment, parent_lp)
          else
            urls.each_with_index do |url, index|
              rows << comment_attrs(comment, parent_lp, index + 1, url)
            end
          end
        end

        rows
      end

      # Returns a hash of serialized attributes for a single comment row,
      # including optional sub-numbering for attachments and an attachment URL.
      def comment_attrs(comment, parent_lp, child_lp = nil, attachment_url = nil)
        {
          lp: build_lp(parent_lp, child_lp),
          custom_proposal_weight: comment.root_commentable.weight,
          custom_proposal_title: comment.root_commentable.title,
          signature: comment.signature,
          body: translated_attribute(comment.body),
          created_at: I18n.l(comment.created_at, format: :short),
          email: comment.email,
          district: comment.district.present? ? translated_attribute(comment.district.name) : "",
          age: comment.age.present? ? I18n.t(comment.age, scope: "decidim.comments.age", default: "") : "",
          gender: comment.gender.present? ? I18n.t(comment.gender, scope: "decidim.users.gender.public_post", default: "") : "",
          url: attachment_url
        }
      end

      private

      def column_name_translation(column)
        I18n.t(column, scope: "decidim.custom_proposals.export.comment")
      end

      def column_width(key)
        case key
        when :auto then nil
        when :body then 100
        when :url then 60
        else
          30
        end
      end
    end
  end
end
