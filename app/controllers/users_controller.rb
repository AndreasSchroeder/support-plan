class UsersController < ApplicationController
    # filters
    before_action :logged_in_user, only: [:index, :show, :edit, :update, :destroy]
    before_action :admin_user, only: [:index, :edit, :update, :destroy]

  # lists all users
  def index
    @user = User.new
    @users = User.where(planable: true)
  end

  # for fill userdata
  def create
    @users = User.all
    @user = User.find_by(email: checks_email_alternativ(params[:user][:email].downcase))
    if @user
      @user.update(planable: true)
      flash[:success] = "Benutzer wurde reaktiviert."
    elsif @user = User.new(email: params[:user][:email])
      if is_ldap? @user.email
        if @user.save
          @user.update(email: checks_email_alternativ(@user.email))
          flash[:success] = "Benutzer wurde aktiviert."
        end
      else
      flash[:danger] = "User nicht im LDAP-System."
      end
    else
      flash[:danger] = "Anlegen ist fehlgeschlagen."
    end
    redirect_to action: :index
  end

  # action for deleting
  def destroy
    User.find(params[:id]).update(planable: false)
    flash[:success] = "Benutzer wurde gelöscht"
    redirect_to action: :index
  end

  private

  # whitelisteed params
  def question_params
    params.require(:user).permit(:email)
  end

  # Confirms a logged-in user.
    def logged_in_user
        unless logged_in?
            store_location
            flash[:danger] = "Please log in."
            redirect_to login_url
        end
    end

    # Confirms the correct user.
    def correct_user
        @user = User.find(params[:id])
        redirect_to(root_url) unless current_user?(@user)
    end

    # Confirms an admin user.
    def admin_user
        redirect_to(root_url) unless current_user.is_admin?
    end
end
