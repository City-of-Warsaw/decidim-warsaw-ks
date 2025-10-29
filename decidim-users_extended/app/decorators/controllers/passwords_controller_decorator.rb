# frozen_string_literal: true

Decidim::Devise::PasswordsController.class_eval do
  helper_method :minimum_password_length

  # overwritten method
  # added validation for the password
  # instead of set_minimum_password_length - set_flash_message
  def update
    self.resource = resource_class.reset_password_by_token(resource_params)
    validate_password_params(resource, resource_params) # added validation
    yield resource if block_given?

    if resource.errors.empty?
      resource.unlock_access! if unlockable?(resource)
      if Devise.sign_in_after_reset_password
        flash_message = resource.active_for_authentication? ? :updated : :updated_not_active
        set_flash_message!(:notice, flash_message)
        resource.after_database_authentication
        sign_in(resource_name, resource)
      else
        set_flash_message!(:notice, :updated_not_active)
      end
      respond_with resource, location: after_resetting_password_path_for(resource)
    else
      flash_message = resource.errors[:reset_password_token].any? ? :reset_password_token_invalid : :form_errors
      set_flash_message!(:error, flash_message, now: true) # added flash message
      respond_with resource
    end
  end

  private

  def validate_password_params(resource, resource_params)
    password = resource_params[:password]
    resource.errors.add(:password, 'To hasło nie spełnia poniższych warunków') unless correct_password(password)
  end

  def correct_password(pass)
    !!pass.match(/[a-z]/) && !!pass.match(/[A-Z]/) && !!pass.match(/[0-9]/) && !!pass.match(/[!@#$%^&*()_,<>';\\\]\[|":{}=\-\+\.?]/)
  end

  def minimum_password_length
    Decidim::User.password_length.min
  end
end
