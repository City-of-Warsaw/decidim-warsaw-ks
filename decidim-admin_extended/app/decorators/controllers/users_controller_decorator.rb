# frozen_string_literal: true

Decidim::Admin::UsersController.class_eval do
  before_action :check_params_default, only: [:index]

  helper_method :user

  def edit
    @form = form(Decidim::AdminExtended::AdminUserForm).from_model(user)
  end

  def update
    @form = form(Decidim::AdminExtended::AdminUserForm).from_params(params)

    Decidim::AdminExtended::UpdateAdminUser.call(@form, user, current_user) do
      on(:ok) do
        flash[:notice] = I18n.t("users.update.success", scope: "decidim.admin")
        redirect_to users_path
      end

      on(:invalid) do
        flash.now[:alert] = I18n.t("users.create.error", scope: "decidim.admin")
        render :edit
      end
    end
  end

  def export
    @users = collection
    create_log(current_user, 'admins_list_export')
    respond_to do |format|
      format.xlsx do
        response.headers['Content-Disposition'] = "attachment; filename=Lista_użytkowników_aktywnych_i_nieaktywnych_#{Date.current}.xlsx"
      end
    end
  end

  def activate_ad
    user
    @user.update_column('ad_access_deactivate_date', nil)
    create_log(@user, 'activate_ad_user')
    flash[:notice] = 'Aktywowano dostęp użytkownika wewnętrznego'
    redirect_to users_path(q:{ad_active_eq: 'active'})
  end

  def deactivate_ad
    user
    @user.update_column('ad_access_deactivate_date', Time.current)
    create_log(@user, 'deactivate_ad_user')
    flash[:notice] = 'Dezaktywowano dostęp użytkownika wewnętrznego'
    redirect_to users_path(q:{ad_active_eq: 'inactive'})
  end

  private

  # overwritten method
  # remove admin users filters
  # add AD role
  def filters
    [:ad_role_eq, :ad_active_eq]
  end

  # overwritten method
  # add AD role
  # add editorial
  def search_field_predicate
    :name_or_nickname_or_email_or_ad_role_or_editorial_cont
  end

  # overwritten method
  # remove admin users filters
  # add AD role
  def filters_with_values
    {
      ad_role_eq: %w(Decidim_ks_admin Decidim_ks_koordynator Decidim_ks_moderator),
      ad_active_eq: %w(active inactive)
    }
  end

  def create_log(resource, log_type)
      Decidim.traceability.perform_action!(
        log_type,
        resource,
        current_user,
        visibility: 'admin-only'
    )
  end

  def check_params_default
    redirect_to users_path(q:{ad_active_eq: 'active'}) unless params[:q].present?
  end
end
