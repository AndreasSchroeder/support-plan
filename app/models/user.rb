class User < ApplicationRecord
  has_many :semester_plan_connections
  has_many :semester_break_plan_connections

  before_save   :downcase_email

  # validates email
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  validates :email, presence: true, length: { maximum: 255 },
        format: { with: VALID_EMAIL_REGEX },
        uniqueness: { case_sensitive: false }, allow_blank: false


  # returns the name or infotext
  def get_name
    if self.first_name.nil?
      return "Die Daten dieses Nutzers sind nach dem ersten Login verfügbar."
    else
      return "#{self.first_name} #{self.last_name}"
    end
  end

  # returns the sum of all hours of planable users
  def self.hours_sum
    User.where(planable: true).inject(0){|sum,x| sum + x.hours.to_i }
  end

  # returns the sum of the shifts (rounded)
  def self.shifts_sum
    User.where(planable: true).inject(0){|sum,x| sum + x.get_shifts_round.to_i }
  end

  # return hours of user
  def get_hours
    self.hours.to_i
  end

  # returns shift qut
  def get_shift_quot
    ((20.to_f/User.hours_sum.to_f) * self.get_hours.to_f).to_f
  end

  # rounds shifts
  def get_shifts_round
    (self.get_shift_quot + 0.5).to_i
  end

  # returns hash with amount of shifts per supporter
  def self.supporter_amount_of_shifts
    # initialize and fill
    shifts = []
    User.where(planable: true).each do |user|
      shifts << {user: user.id, shifts: user.get_shifts_round}
    end
    # sum up
    sum = User.shifts_sum

    # flatten hash, so sum is 20
    while sum > 20
      shifts.sort_by! { |item|
        [item[:shifts]* -1 , User.find(item[:user]).hours ]
      }
      shifts[0][:shifts] -= 1
      sum -=1
    end
    while sum < 20
      shifts.sort_by! { |item|
        [item[:shifts] , User.find(item[:user]).hours * -1]
      }
      shifts[0][:shifts] += 1
      sum +=1

    end
    #return hash
    shifts
  end

  def self.reduce_shifts user, shifts
    shifts.each do |s|
      if s[:user] == user
        s[:shifts] -= 1
      end
    end
    shifts
  end

  # returns hash with amaount of shifts for each supporter
  # old version.
  def self.supporter_amount_of_shifts_old
    # initialize hash
    shifts = []
    User.where(planable: true).each do |user|
      shifts << {user: user.id, shifts: user.get_shifts_round}
    end
    sum = User.shifts_sum
    rnd = Random.new

    # if to much hours, eleminate some
    if sum >20
      dif =  sum - 20

      # get all users with minimal hours
      set = User.min_supporters dif
      len = set.length() -1

      # repeat until diff = 0
      while dif != 0
         # minor chance to elimate shift from any supporter
        i = rnd.rand(0..(len))
        any = set[i].id
        users = shifts.select{|u| u[:user] == any  }
        if users.first[:shifts] > 1
          users.first[:shifts] -= 1
          dif -= 1
          set.delete_at(i)
          len -= 1
        end
      end

    # analog as above
    elsif sum < 20
      dif =   20 - sum
      set = User.max_supporters dif
      len = set.length() -1

      while dif != 0

        i = rnd.rand(0..(len))
        any = set[i].id
        users = shifts.select{|u| u[:user] == any  }
        if users.first[:shifts] > 1
          users.first[:shifts] += 1
          dif -= 1
          set.delete_at(i)
          len -= 1
        end
      end
    end
    shifts
  end

  # gets all supporters with minimal hours
  def self.min_supporters(diff )
    User.order(:hours).take(diff+ 1)
  end

  # gets all supporters with maximal hours
  def self.max_supporters(diff)
    User.order(hours: :desc).take(diff + 1)
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
