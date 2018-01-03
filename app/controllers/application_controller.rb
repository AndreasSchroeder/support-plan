class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  include SessionsHelper
  include ApplicationHelper

      # conect to LDAP servers and update the given user. This method will be called if a login occured with an @uos.de or @uni-osnabrueck.de
    # adresse
    def connect (name, password, user)
        ldap = Net::LDAP.new :host => "ldap.uni-osnabrueck.de",
            :port => "389",
            :encryption => :start_tls,
            :base => "ou=people,dc=uni-osnabrueck,dc=de",
        :auth => {
            :method => :simple,
            :username => "uid="+name+", ou=people,dc=uni-osnabrueck,dc=de",
            :password => password,
            :attributes =>'uid'
        }
        # test if connection is successfull
        if ldap.bind
            puts "Connection successful!  Code:  #{ldap.get_operation_result.code}, message: #{ldap.get_operation_result.message}"
        else
            puts "Connection failed!  Code:  #{ldap.get_operation_result.code}, message: #{ldap.get_operation_result.message}"
            return false
        end
        # search for user and update him
        filter = Net::LDAP::Filter.eq( "uid", name )
        treebase = "dc=uni-osnabrueck,dc=de"
        ldap.search( :base => treebase, :filter => filter ) do |entry|
            given_name = build entry.givenName
            last_name =  build entry.sn
            mail =       build entry.mail
            user.update_attribute :email, mail
            user.update_attribute :first_name, given_name
            user.update_attribute :last_name, last_name
            user.save
            return true
        end
    end

    # Checks if a user is in LDAP Database
    def is_ldap? (email)
        #Domain of User is Uni Osna?
        domain = email.downcase.split("@").last.strip
        if domain == "uni-osnabrueck.de" || domain == "uos.de"
            # autehntificate if possible
            name = email.downcase.split("@").first.strip
            ldap = Net::LDAP.new :host => "ldap.uni-osnabrueck.de",
                :port => "389",
                :encryption => :start_tls,
                :base => "ou=people,dc=uni-osnabrueck,dc=de" # the base of your AD tree goes here,
                # true if possible
            filter = Net::LDAP::Filter.eq("uid", "#{name}")
            p name
            ldap.search(base: "dc=uni-osnabrueck,dc=de", filter: filter) do |entry|
                if entry
                    return true
                end
            end
        end
        return false
    end

    # searchs database for a user with uni-adresse
    def checks_email_alternativ (email)
        array = email.split("@")
        p "DOMAIN: #{array.last.downcase}"
        if array.last.downcase.strip == "uni-osnabrueck.de" || array.last.downcase.strip == "uos.de"
            mail = array.first + "@uni-osnabrueck.de"
            @user = User.find_by(email: mail)
            if !@user
                mail = array.first + "@uos.de"
            end

            return mail.downcase
        else
            return email.downcase
        end
    end

    private

    # builds string from datatype, neccessary for Ldap-multi-fields
    def build(data)
        if data == nil
            return ""
        elsif data.kind_of?(Array)
            string = ""
            data.each do |d|
                string += "#{d}"
            end
            return string
        else
            return data
        end
    end

    # Confirms a logged-in user.
    def logged_in_user
        unless logged_in?
            store_location
            flash[:danger] = "Please log in."
            redirect_to login_url
        end
    end

    # encodes a str to utf8
    def encode (str)
        return Mail::Encodings.unquote_and_convert_to(str, 'utf-8' ).unpack "M"
end
end
