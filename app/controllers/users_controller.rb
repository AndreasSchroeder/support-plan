class UsersController < ApplicationController
    # filters
    before_action :logged_in_user, only: [:index, :show, :edit, :update, :destroy]
    before_action :admin_user, only: [:index, :edit, :destroy]

  # lists all users
  def index
    @user = User.new
    @users = User.where(inactive: false)
  end

  def show
    @user = User.find(params[:id])
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
    User.find(params[:id]).update(inactive: true)
    flash[:success] = "Benutzer wurde gelöscht"
    redirect_to action: :index
  end

  def update
    params["input"].each do |k, v|
      id = k.split(";").first
      type = k.split(";").last
      value = v
      p "#{id} #{type} #{value}"
      user = User.find(id.to_i)
      p user
      p
      if type == "A"
        user.update(is_admin: value.to_i)
      elsif type == "H"
        user.update(hours: value.to_i)
      elsif type == "P"
        user.update(planable: value.to_i)
      end
      p user

    end
    flash[:success] = "Vorgang abgeschlossen."

    redirect_back(fallback_location: root_path)
  end


  private

  # whitelisteed params
  def question_params
    params.require(:user).permit(:email)
  end

  def question_params_update
    params.require(:user).permit(:hours, :is_admin, :planable)
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
