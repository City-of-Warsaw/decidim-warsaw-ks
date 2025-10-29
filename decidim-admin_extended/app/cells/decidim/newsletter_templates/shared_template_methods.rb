# frozen_string_literal: true

module Decidim
  module NewsletterTemplates
    module SharedTemplateMethods
      def title
        parse_interpolations(uninterpolated_title, recipient_user, newsletter.id)
      end

      def uninterpolated_title
        translated_attribute(model.settings.title)
      end

      def lead
        parse_interpolations(uninterpolated_lead, recipient_user, newsletter.id)
      end

      def uninterpolated_lead
        translated_attribute(model.settings.lead)
      end

      def introduction
        parse_interpolations(uninterpolated_introduction, recipient_user, newsletter.id)
      end

      def uninterpolated_introduction
        translated_attribute(model.settings.introduction)
      end

      def body
        parse_interpolations(uninterpolated_body, recipient_user, newsletter.id)
      end

      def uninterpolated_body
        translated_attribute(model.settings.body)
      end

      def has_main_image?
        newsletter.template.images_container.main_image.attached?
      end

      def main_image
        image_tag main_image_url
      end

      def main_image_url
        newsletter.template.images_container.attached_uploader(:main_image).url
      end

      def organization_primary_color
        organization.colors["primary"]
      end

      def logo_or_name_link
        return link_to organization.name, decidim.root_url(host: organization.host) unless organization.logo.attached?

        if File.extname(organization.attached_uploader(:logo).path) == ".svg"
          File.open(ActiveStorage::Blob.service.path_for(organization.logo.key), "rb") do |file|
            raw file.read
          end
        else
          link_to decidim.root_url(host: organization.host) do
            image_tag current_organization.attached_uploader(:logo).url,
                      alt: current_organization_name
          end
        end
      rescue Errno::ENOENT
        'brak loga'
      end

      def highlighted_banner_link
        return unless organization.highlighted_content_banner_image.attached?

        link_to organization.official_url do
          image_tag current_organization.attached_uploader(:highlighted_content_banner_image).url,
                    alt: current_organization_name
        end
      end

      def footer
        parse_interpolations(uninterpolated_footer, recipient_user, newsletter.id)
      end

      def uninterpolated_footer
        model.settings.footer
      end
    end
  end
end
