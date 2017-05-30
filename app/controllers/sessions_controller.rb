class SessionsController < ApplicationController
  def new
  end

  def create
    user = User.find_by(email: checks_email_alternativ(params[:session][:email].downcase))
    if user == User.find_by(email: "admin@admintest.de")
      log_in user
          flash[:success] = 'Erfolgreich eingeloggt'
    else
      if user != nil
        email = checks_email_alternativ(params[:session][:email].downcase)
        if is_ldap?(email)
          uname = email.split("@").first
          if connect(uname, params[:session][:password], user)
            log_in user
            flash[:success] = 'Erfolgreich eingeloggt'

          else
            flash[:danger] = 'Passwort nicht korrekt'
          end
        else
          # Create an error message.
          flash[:danger] = 'User nicht im LDAP-System. Wenden Sie sich an einen Admin'
        end
      else
        flash[:danger] = 'User nicht im System. Wenden Sie sich an einen Admin'
      end
    end
    redirect_to root_url
  end

  def destroy
    log_out if logged_in?
    redirect_to root_url
  end
end
