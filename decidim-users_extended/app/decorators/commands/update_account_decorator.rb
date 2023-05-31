# frozen_string_literal: true

# A update object used to update the current logged user from user panel
# Class was provided with attributes for adding more personal information about current user, to /account
Decidim::UpdateAccount.class_eval do

  private

  # OVERWRITTEN DECIDIM METHOD
  def update_personal_data
    @user.name = @form.name
    @user.nickname = @form.nickname
    @user.email = @form.email
    @user.personal_url = @form.personal_url
    @user.about = @form.about
    # added custom attributes:
    # gender - allows to choose gender for the user
    # birth year - allows to fill in date of birth for the user
    # zip code - allows to fill in zip code for the user
    # district - allows to choose district for the user
    @user.gender = @form.gender
    @user.birth_year = @form.birth_year
    @user.zip_code = @form.zip_code
    @user.district = scope
  end

  def scope
    Decidim::Scope.find_by(id: @form.district_id)
  end
end
