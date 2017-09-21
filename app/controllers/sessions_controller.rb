class SessionsController < ApplicationController
  def new
  end

  # login user
  def create
    # find user by given email
    user = User.find_by(email: checks_email_alternativ(params[:session][:email].downcase))
    p user
    # if user is testadmin => login
    if user == User.find_by(email: "admin@admintest.de")
      log_in user
          flash[:success] = 'Erfolgreich eingeloggt'
    else

      # if a user was found
      if user != nil

        # checks alternate forms (uos/uni-osnabrueck)
        email = checks_email_alternativ(params[:session][:email].downcase)

        # checks if user is in rz-database
        if is_ldap?(email)
          uname = email.split("@").first

          # connects to rz-database
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

  # action for deleting users
  def destroy
    log_out if logged_in?
    redirect_to root_url
  end
end
