module ApplicationHelper
    def get_collection s, co
    @collection = []
    @users = User.where(planable: true)
    selected = false
    @users.each do |user|
      if s[:user].to_i == user.id && !co
        selected = true
        @collection << [user.get_name, user.id, {class: "av#{SemesterPlanConnection.find_it_id(user.id, (s[:slot].to_i())).availability}", selected: "" }]
      elsif s[:co].to_i == user.id && co
        selected = true
        @collection << [user.get_name, user.id, {class: "av#{SemesterPlanConnection.find_it_id(user.id, (s[:slot].to_i())).availability}", selected: "" }]
      elsif s[:slot]
        @collection << [user.get_name, user.id, {class: "av#{SemesterPlanConnection.find_it_id(user.id, (s[:slot].to_i())).availability}" }]
      else
        @collection << [user.get_name, user.id]
      end
    end
    if !selected
      @collection << ["(niemand)", nil, {selected: ""}]
    else
      @collection << ["(niemand)", nil]
    end
    @collection
  end

  def get_av s, co
    if co && s[:co]
      return "av#{SemesterPlanConnection.find_it_id(s[:co].to_i, (s[:slot].to_i())).availability}"
    elsif !co && s[:user]
      return "av#{SemesterPlanConnection.find_it_id(s[:user].to_i, (s[:slot].to_i())).availability}"
    end
    return ""
  end

  def get_av_user_slot user, slot
    return "av#{SemesterPlanConnection.find_it(user, slot).availability}"
  end

end
