class SessionsController < ApplicationController
  def new
  end

  def create
    user = User.find_by(email: params[:session][:email].downcase)
    if user != nil
      email = checks_email_alternativ(params[:session][:email].downcase)
      if is_ldap?(email)
        uname = email.split("@").first
        p params[:session][:password]
        if connect(uname, params[:session][:password], user)
          log_in user
          redirect_to user

        else
          flash.now[:danger] = 'Passwort nicht korrekt'
          render 'new'
        end
      else
        # Create an error message.
        flash.now[:danger] = 'User nicht im LDAP-System. Wenden Sie sich an einen Admin'
        render 'new'
      end
    else
      flash.now[:danger] = 'User nicht im System. Wenden Sie sich an einen Admin'
      render 'new'
    end
  end

  def destroy
  end
end
