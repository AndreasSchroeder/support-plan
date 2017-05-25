class UsersController < ApplicationController
    before_action :logged_in_user, only: [:index, :edit, :update, :destroy]
    before_action :admin_user, only: [:index, :edit, :update, :destroy]


  def index
    @user = User.new
    @users = User.all
  end

  def create
    @users = User.all
    if (User.find_by(email: checks_email_alternativ(params[:user][:email].downcase))) == nil
      @user = User.new(question_params)
      if @user.save
        @user.update(email: checks_email_alternativ(@user.email))
        flash[:success] = "Benutzer wurde angelegt."
      else
        flash[:danger] = "Anlegen ist fehlgeschlagen."
      end
    else
      flash[:danger] = "Benutzer existiert bereits"
    end
    redirect_to action: :index
  end

  def destroy
    User.find(params[:id]).destroy
    flash[:success] = "Benutzer wurde gelöscht"
    redirect_to action: :index
  end

  private

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
