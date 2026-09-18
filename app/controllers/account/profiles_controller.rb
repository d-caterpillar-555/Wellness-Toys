# The account holder's own details. Credentials (email and password) are not
# here: they stay with Devise at /account/edit, which requires the current
# password before it changes either.
class Account::ProfilesController < Account::BaseController
  def show
    authorize current_user
  end

  def edit
    authorize current_user
  end

  def update
    authorize current_user
    if current_user.update(profile_params)
      redirect_to account_profile_path, notice: t("account.profile.updated")
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private
    def profile_params
      params.require(:user).permit(:name, :phone)
    end
end
