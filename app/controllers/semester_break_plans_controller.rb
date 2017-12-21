class SemesterBreakPlansController < ApplicationController
  before_action :admin_user, only: [:new, :create, :destroy]
  before_action :set_semester_break_plan, only: [:show, :edit, :update, :destroy]

  # GET /semester_break_plans
  def index
    @semester_break_plans = SemesterBreakPlan.all
  end

  # GET /semester_break_plans/1
  def show
    @semester_break_plan.update_days @users
    @semester_break_plan.update_users
  end

  # GET /semester_break_plans/new
  def new
    @semester_break_plan = SemesterBreakPlan.new
  end

  # GET /semester_break_plans/1/edit
  def edit
  end

  # POST /semester_break_plans
  def create
    @semester_break_plan = SemesterBreakPlan.new(semester_break_plan_params)
    @users = User.users_of_break_plan @semester_break_plan
    if @semester_break_plan.save
      days = DaySlot.days_between @semester_break_plan.start, @semester_break_plan.end
      days.each do |day|
        slot = @semester_break_plan.day_slots.create(start: parse_day(day))
        @users.each do |user|
          slot.semester_break_plan_connections.create(user: user)
        end
      end
      flash[:success] = "Ferien-Support-Plan angelegt."
      redirect_to @semester_break_plan
    else
      render :new
    end
  end

  # PATCH/PUT /semester_break_plans/1
  def update
    if @semester_break_plan.update(semester_break_plan_params)
      flash[:success] = "Ferien-Support-Plan aktualisiert."
      redirect_to @semester_break_plan
    else
      render :edit
    end
  end

  # DELETE /semester_break_plans/1
  def destroy
    @semester_break_plan.update(inactive: true)
    flash[:success] = "Ferien-Support-Plan gelöscht."
    redirect_to semester_break_plans_url
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_semester_break_plan
      @semester_break_plan = SemesterBreakPlan.find(params[:id])
      @slots = @semester_break_plan.day_slots
      @slots.each do |slot|
        slot.delete_if_holiday
      end
      @slots = @semester_break_plan.day_slots
      @users = User.users_of_break_plan @semester_break_plan
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def semester_break_plan_params
      params.require(:semester_break_plan).permit(:start, :end, :name, :free, :solution, day_slots_attributes: [:semester_break_plan_id, :id, semester_break_plan_connections_attributes:[:id, :availability, :user_id, :day_slot_id]])
    end

    # Confirms an admin user.
    def admin_user
      unless current_user.is_admin?
        flash[:danger] = "Keine Berechtigung."
        redirect_to(root_url)
      end
    end
end
