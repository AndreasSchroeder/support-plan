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

  def unplanable
    SemesterPlan.all.each do |plan|
      all_empty = true
      plan.time_slots.each do |slot|
        slot.semester_plan_connections.each do |con|

          if con.availability != 0 && con.user == self
            all_empty = false
          end
        end
      end
      if all_empty
        plan.time_slots.each do |slot|
          slot.semester_plan_connections.each do |con|
            if con.user == self
              con.delete
            end
          end
        end
      end
    end
  end

  def get_name_or_alias
    if self.first_name.nil?
      return "#{self.email.split('@').first}"
    else
      return "#{self.first_name} #{self.last_name}"
    end
  end

  def get_initial
    if self.first_name.nil? || self.last_name.nil?
      return "11"
    else
      return "#{self.first_name.first.upcase}#{self.last_name.first.upcase}"
    end

  end

  def is_planable? plan
    plan.time_slots.each do |slot|
      slot.semester_plan_connections.each do |con|
        if con.user == self
          return true
        end
      end
    end
    return self.planable
  end

  def is_planable_break? plan
    plan.day_slots.each do |slot|
      slot.semester_break_plan_connections.each do |con|
        if con.user == self
          return true
        end
      end
    end
    return self.planable
  end

  def self.users_of_plan_pure plan
    users = []
    User.all.each do |user|
      if user.is_planable?(plan)
        users << user
      end
    end
    User.all.each do |user|
      if user.office
        users << user
      end
    end
    users.uniq
  end


  def self.users_of_plan plan
    users = []
    User.all.each do |user|
      if user.is_planable?(plan) && plan.has_entrys(user)
        users << user
      end
    end
    User.all.each do |user|
      if user.office
        users << user
      end
    end
    users.uniq
  end

  def self.users_of_break_plan plan
    users = []
    User.all.each do |user|
      if user.is_planable_break? plan
        users << user
      end
    end
    User.all.each do |user|
      if user.office
        users << user
      end
    end
    users.uniq
  end

  def self.users_of_plan_without_office plan
    users = []
    User.all.each do |user|
      if user.is_planable?(plan) && plan.has_entrys(user)
        users << user
      end
    end
    without =[]
    User.all.each do |user|
      if user.office
        without << user
      end
    end

    users.uniq - without.uniq
  end

  # returns the sum of all hours of planable users
  def self.hours_sum
    User.where(planable: true).inject(0){|sum,x| sum + x.hours.to_i }
  end

  # returns the sum of the shifts (rounded)
  def self.shifts_sum amount
    User.where(planable: true).inject(0){|sum,x| sum + x.get_shifts_round(amount).to_i }
  end

  # return hours of user
  def get_hours
    self.hours.to_i
  end

  # returns shift qut
  def get_shift_quot amount
    ((amount.to_f/User.hours_sum.to_f) * self.get_hours.to_f).to_f
  end

  # rounds shifts
  def get_shifts_round amount
    (self.get_shift_quot(amount) + 0.5).to_i
  end

  # returns hash with amount of shifts per supporter
  def self.supporter_amount_of_shifts amount
    rnd = Random.new
    # initialize and fill
    shifts = []
    User.where(planable: true, inactive: false).each do |user|
      shifts << {user: user.id, shifts: user.get_shifts_round(amount)}
    end
    # sum up
    sum = User.shifts_sum(amount)

    # flatten hash, so sum is 20
    while sum > amount
      shifts.sort_by! { |item|
        [item[:shifts]* -1 , User.find(item[:user]).hours, rnd.rand ]
      }
      shifts[0][:shifts] -= 1
      sum -=1
    end
    while sum < amount
      shifts.sort_by! { |item|
        [item[:shifts] , User.find(item[:user]).hours * -1, rnd.rand]
      }
      shifts[0][:shifts] += 1
      sum +=1

    end
    #return hash
    shifts
  end

  def self.reduce_shifts user, shifts
    shifts.each do |s|
      if s[:user] == user && s[:shifts] != 0
        s[:shifts] -= 1

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
