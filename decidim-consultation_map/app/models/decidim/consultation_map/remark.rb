# frozen_string_literal: true

require_dependency "file_form_validator"

module Decidim
  module ConsultationMap
    class Remark < ApplicationRecord
      include Decidim::HasComponent
      include Decidim::Traceable
      include Decidim::Loggable
      include Decidim::Searchable
      include Decidim::Reportable
      include Decidim::Authorable
      include Decidim::Comments::CommentableWithComponent
      include Decidim::Followable
      include Decidim::Resourceable
      include Decidim::Publicable

      component_manifest_name "consultation_map"

      after_commit :enqueue_map_remark_geocoding, on: :create

      has_many_attached :files

      belongs_to :component, foreign_key: :decidim_component_id, class_name: "Decidim::Component"
      belongs_to :category, foreign_key: :decidim_category_id, class_name: "Decidim::ConsultationMap::Category", optional: true
      belongs_to :district, class_name: "Decidim::Scope", optional: true

      has_many :email_follows,
               as: :followable,
               foreign_key: "decidim_followable_id",
               foreign_type: "decidim_followable_type",
               class_name: "Decidim::CoreExtended::EmailFollow",
               dependent: :destroy

      delegate :participatory_space, :organization, to: :component
      delegate :title, to: :component

      scope :user_remarks, ->(user_id) { where(decidim_author_type: "Decidim::UserBaseEntity", decidim_author_id: user_id) }

      scope :with_any_category, lambda { |*categories|
        cat_ids = categories.flatten.compact.map(&:to_i)
        return self unless cat_ids.any?

        joins(:category).where(decidim_consultation_map_categories: { id: cat_ids })
      }
      scope :without_system_hidden, -> { where.not(body: "system_generated_hidden_map_remark") }

      validates :files, file_form: {
        max_size: 50.megabytes,
        acceptable_types:
          %w(
            image/jpg image/jpeg image/gif image/png image/bmp
            application/pdf application/msword application/vnd.openxmlformats-officedocument.wordprocessingml.document
          )
      }

      searchable_fields(
        {
          participatory_space: { component: :participatory_space },
          A: :body,
          datetime: :created_at
        },
        index_on_create: ->(remark) { !remark.body.start_with?("system_generated_hidden_") },
        index_on_update: ->(remark) { !remark.body.start_with?("system_generated_hidden_") }
      )

      def deleted?
        false
      end

      def can_be_deleted?
        false
      end

      def allow_edition?(remark_token)
        return false if remark_token.blank?

        token == remark_token
      end

      def title
        I18n.t("activemodel.attributes.remark.title", signature: author_signature)
      end

      def author_signature
        if author.is_a?(Decidim::CoreExtended::UnregisteredAuthor)
          signature.presence || I18n.t("decidim.comments_extended.models.comment.fields.unregistered_author")
        else
          author.name
        end
      end

      def map_location(to_json = false)
        default_icon = component.attributes["settings"]["custom"]["file_id"].present? ? Decidim::Repository::File.svgs.find(component.attributes["settings"]["custom"]["file_id"]) : nil
        default_color = component.attributes["settings"]["custom"]["color"].present? ?  component.attributes["settings"]["custom"]["color"] : "#197893"
        all_locations = {}
        all_locations["lat"] = latitude
        all_locations["lng"] = longitude
        all_locations["id"] = id
        all_locations["category_id"] = category&.id
        all_locations["category_name"] = category&.name
        all_locations["category_color"] = category.nil? ? default_color : category.color
        all_locations["category_icon"] =
          if category.nil?
            default_icon.nil? ? "" : default_icon.file.download.gsub('\"', "'")
          else
            category.file_id.nil? ? "" : category.inline_svg(category.file).gsub('\"', "'")
          end

        to_json ? all_locations.to_json : all_locations
      end

      # Public: Overrides the `comments_have_votes?` Commentable concern method.
      def comments_have_votes?
        true
      end

      # Overwritten method.
      # Map Remarks can’t be commented if:
      # - it's not visible or not published
      # - the users_action_end_date has passed
      # Only AD users are allowed to comment.
      def user_allowed_to_comment?(user)
        return false unless visible?
        return false unless published?
        # scenario when component is closed
        return false if component.users_action_end_date&.past?

        # scenario when AD user is present
        user.present? && user.ad_role?
      end

      def visible?
        participatory_space.try(:visible?) && component.try(:published?) && published?
      end

      def published?
        !hidden?
      end

      def presenter
        Decidim::ConsultationMap::RemarkPresenter.new
      end

      # Public: Overrides the `reported_attributes` Reportable concern method.
      def reported_attributes
        [:body, :signature]
      end

      # Public: Overrides the `reported_searchable_content_extras` Reportable concern method.
      def reported_searchable_content_extras
        [normalized_author.name]
      end

      def mounted_params
        {
          :host => organization.host,
          :resource_id => id,
          :component_id => component.id,
          "#{component.participatory_space.underscored_name}_slug".to_sym => component.participatory_space.slug
        }
      end

      def self.ransackable_scopes(_auth_object = nil)
        [:with_any_category]
      end

      def self.participatory_space_manifest
        Decidim.find_participatory_space_manifest(Decidim::ParticipatoryProcess.name.demodulize.underscore.pluralize)
      end

      def author_district
        if author.is_a?(Decidim::CoreExtended::UnregisteredAuthor)
          district&.name
        else
          author.district&.name
        end
      end

      def author_email
        if author.is_a?(Decidim::CoreExtended::UnregisteredAuthor)
          email
        else
          author&.email
        end
      end

      # Na warsztatach ustaliliśmy przedziały wiekowe oraz to, że mieszkaniec zalogowany powinien podawać
      # w swoim koncie rok urodzenia - ale prezentować miał się ten wiek w przedziałach.
      def author_age_range
        if author.is_a?(Decidim::CoreExtended::UnregisteredAuthor)
          age.present? ? I18n.t("age.#{age}", scope: "decidim.comments") : nil
        else
          author.age_range.present? ? I18n.t("age.#{author.age_range}", scope: "decidim.comments") : nil
        end
      end

      def author_gender
        if author.is_a?(Decidim::CoreExtended::UnregisteredAuthor)
          gender.present? ? I18n.t("gender.public_post.#{gender}", scope: "decidim.users") : nil
        else
          author.gender.present? ? I18n.t("gender.public_post.#{author.gender}", scope: "decidim.users") : nil
        end
      end

      def participatory_space
        component&.participatory_space
      end

      def organization
        component&.organization
      end

      # overwritten method
      # make blank collection due for decidim-core-0.29.3/lib/decidim/reportable.rb:27
      # only admin administers information
      def admins
        Decidim::User.none
      end

      # overwritten method
      # make blank collection due for decidim-core-0.29.3/lib/decidim/reportable.rb:27
      # only admin administers information
      def moderators
        Decidim::User.none
      end

      private

      def enqueue_map_remark_geocoding
        Decidim::ConsultationMap::GeocodeRemarkAddressJob.perform_later(self)
      end
    end
  end
end
