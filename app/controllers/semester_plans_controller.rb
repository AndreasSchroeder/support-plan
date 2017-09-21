require 'json'
class SemesterPlansController < ApplicationController
  include SemesterPlansHelper


      # filters
  before_action :logged_in_user, only: [:index, :show, :edit, :update, :destroy]
  before_action :admin_user, only: [:index, :edit, :update, :destroy]
  # action for new plan
  def new
    if current_user.is_admin
      @plan = SemesterPlan.new
    else
      redirect_to root_path
    end
  end

  # action to fill plan with data
  def create
    @plan = SemesterPlan.new(plan_params)
      if @plan.save
        ["Montag", "Dienstag", "Mittwoch", "Donnerstag", "Freitag"].each do |day|
          start_time = 8
          4.times do
            timeslot = @plan.time_slots.create!(start: start_time, end: start_time + 2, day: day)
            start_time += 2
          end
        end
        flash[:success] = "Erstellen erfolgreich"
        redirect_to semester_plan_path @plan
      else
        flash[:danger] = "Erstellen fehlgeschlagen"
        redirect_to new_semester_plan_path
      end

  end

  def index
  end



  # action for showing a plan. Users are able to fill in Shiftavailibility
  def show
    @plan = SemesterPlan.find(params[:id])
    @users = []
    @users = User.users_of_plan @plan
    @slots = []
    @options = {0 => "manuellen Plan erstellen", 1 => "gültige Lösungen berechnen lassen", 2 => "hinreichend optimale Lösung berechnen lassen"}
    @users.each do |user|
      found = !SemesterPlanConnection.are_build?(user, @plan)
      @plan.time_slots.each do |slot|
        type = slot_type slot
        if found
          @slots << SemesterPlanConnection.create(user: user, time_slot: slot, typus: type, availability: 0)
        else
          @slots << SemesterPlanConnection.find_it(user, slot)
        end
      end
    end
  end

  # splits post-actions into rigth actions
  def handle
    # for user input
    if params["connections"]
      connect(params)
      redirect_to action: "show"
    # starts optimization of plan or creats at least valid plan if possible
    elsif params["optimisation"]
      @plan = SemesterPlan.find(params[:id])
      if @plan.ready_to_plan?
        optimize(params)
      else
        flash[:warning] = "Abbruch! Nicht alle Einträge vorgenommen!"
        redirect_to action: "show"

      end
    # activate plan for user input
    elsif params["free"]
      flash[:success] = "Plan zur Bearbeitung freigegeben"
      SemesterPlan.find(params[:id]).update(free: true)
       redirect_to action: "show"
    end


  end



  private
  # whitelistet parameters
  def plan_params
    params.require(:semester_plan).permit(:start, :end, :name)
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
