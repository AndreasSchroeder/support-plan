class User < ApplicationRecord
  has_many :semester_plan_connections
  has_many :semester_break_plan_connections

  before_save   :downcase_email

  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  validates :email, presence: true, length: { maximum: 255 },
        format: { with: VALID_EMAIL_REGEX },
        uniqueness: { case_sensitive: false }, allow_blank: false    


  def get_name
    if self.first_name.nil?
      return "Die Daten dieses Nutzers sind nach dem ersten Login verfügbar."
    else
      return "#{self.first_name} #{self.last_name}"
    end
  end 

  
  def is_admin?
    return self.is_admin
  end

  private

  # Converts email to all lower-case.
  def downcase_email
    self.email = email.downcase
  end

end
