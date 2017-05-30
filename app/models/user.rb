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

  def self.hours_sum
    User.where(planable: true).inject(0){|sum,x| sum + x.hours.to_i }
  end

  def self.shifts_sum 
    User.where(planable: true).inject(0){|sum,x| sum + x.get_shifts_round.to_i }
  end

  def get_hours
    self.hours.to_i
  end

  def get_shift_quot
    ((20.to_f/User.hours_sum.to_f) * self.get_hours.to_f).to_f
  end

  def get_shifts_round
    (self.get_shift_quot + 0.5).to_i
  end

  def self.supporter_amount_of_shifts
    shifts = []
    User.where(planable: true).each do |user| 
      shifts << {user: user.id, shifts: user.get_shifts_round}
    end
    sum = User.shifts_sum
    rnd = Random.new
    if sum >20 
      dif =  sum - 20
      set = User.min_supporters
      len = set.length() -1

      while dif != 0
         if rnd.rand > 0.98
          user = shifts[rnd.rand(0..(shifts.length()-1))]
          if user[:shifts] > 1
            user[:shifts] -= 1
            dif -= 1
          end
        else 
          any = set[rnd.rand(0..(len))].id
          users = shifts.select{|u| u[:user] == any  }
          if users.first[:shifts] > 1
            users.first[:shifts] -= 1
            dif -= 1
          end
        end
      end

    elsif sum < 20 
      p "SUUUUUUUUUUUUUUUUUUUUUUUUUUUUM"
      p sum
      dif =   20 - sum
      set = User.max_supporters
      len = set.length() -1

      while dif != 0
         if rnd.rand > 0.98
          user = shifts[rnd.rand(0..(shifts.length()-1))]
          if user[:shifts] > 1
            user[:shifts] += 1
            dif -= 1
          end
        else 
          any = set[rnd.rand(0..(len))].id
          users = shifts.select{|u| u[:user] == any  }
          if users.first[:shifts] > 1
            users.first[:shifts] += 1
            dif -= 1
          end
        end

      end
    end
    shifts
  end

  def self.min_supporters
    User.where(hours: User.where(planable: true).order(:hours).first.hours)
  end

  def self.max_supporters
    User.where(hours: User.where(planable: true).order(hours: :desc).first.hours)
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
