# frozen_string_literal: true

Decidim::NewslettersController.class_eval do
  layout "decidim/newsletter_base", only: [:show]

  # overwritten: change generated token for unsubscribe action
  def show
    @user = current_user
    @organization = current_organization

    raise ActionController::RoutingError, "Not Found" unless newsletter.sent?

    @encrypted_token = Decidim::NewsletterEncryptor.sent_at_encrypted(@user.id, @user.class.to_s, 'newsletter') if @user.present?
  end

  # overwritten unsubscribe method to add
  # unregistered authors -add to possibility to unsubscribe from link
  def unsubscribe
    return redirect_to root_path, alert: t("newsletters.unsubscribe.error", scope: "decidim") if params[:u].blank?

    decrypted_string = Decidim::NewsletterEncryptor.decrypt_data(params[:u]).split("-")
    resource_id = decrypted_string.first
    resource_type = decrypted_string.second
    source_message_type = decrypted_string.third
    source_message_id = decrypted_string.fourth

    return redirect_to root_path, alert: t("newsletters.unsubscribe.error", scope: "decidim") if resource_id.nil? || resource_type.nil?

    resource = resource_type.constantize
    resource_id = resource_id.to_i

    if source_message_type.nil? || source_message_type == "newsletter"
      if ["Decidim::CoreExtended::UnregisteredAuthor", "Decidim::CoreExtended::EmailFollow"].include?(resource_type)
        resource.find_by(id: resource_id).destroy
      elsif resource_type == "Decidim::User"
        user = resource.find_by(id: resource_id)
        user.update(newsletter_notifications_at: nil)
      else
        return redirect_to root_path, alert: t("newsletters.unsubscribe.error", scope: "decidim")
      end
    else
      source_message_type = source_message_type.constantize
      source_message_id = source_message_id.to_i
      source = source_message_type.find_by(id: source_message_id)

      source = source.participatory_space if "Decidim::Component" == source_message_type.to_s

      if ["Decidim::CoreExtended::UnregisteredAuthor", "Decidim::CoreExtended::EmailFollow"].include?(resource_type)
        resource.find_by(id: resource_id).destroy
      else
        unless source_message_type.nil? && source_message_id.nil? && source.nil?
          user = resource.find_by(id: resource_id)
          Decidim::Follow.find_by(user:, followable: source).destroy! if user && user.follows?(source)
          source.email_follows.find_by(email: user.email).destroy! if source.email_follows.find_by(email: user.email)
        end
      end
    end

    flash[:notice] = t("newsletters.unsubscribe.success", scope: "decidim")
    redirect_to root_path
  end
end
