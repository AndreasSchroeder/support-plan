class HolidaysController < ApplicationController
  before_action :set_holiday, only: [:show, :edit, :update, :destroy]
  before_action :admin_user

  # GET /holidays
  # GET /holidays.json
  def index
    @holidays = Holiday.all.where("day > ?", Time.now).order(:day)
  end

  # GET /holidays/1
  # GET /holidays/1.json
  def show
  end

  # GET /holidays/new
  def new
    @holiday = Holiday.new
  end

  # GET /holidays/1/edit
  def edit
  end

  # POST /holidays
  # POST /holidays.json
  def create
    @holiday = Holiday.new(holiday_params)

    if @holiday.save
      flash[:success] = "Feiertag angelegt."
      redirect_to @holiday
    else
      render :new 
    end
  end

  # PATCH/PUT /holidays/1
  # PATCH/PUT /holidays/1.json
  def update
    if @holiday.update(holiday_params)
      flash[:success] = "Feiertag aktualisiert."
      redirect_to @holiday
    else
      render :edit 
    end
  end

  # DELETE /holidays/1
  # DELETE /holidays/1.json
  def destroy
    @holiday.destroy
    flash[:success] = "Feiertag gelöscht."
    redirect_to holidays_url
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_holiday
      @holiday = Holiday.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def holiday_params
      params.require(:holiday).permit(:day, :name)
    end

    # Confirms an admin user.
    def admin_user
      unless current_user.is_admin?
        flash[:danger] = "Keine Berechtigung."
        redirect_to(root_url)
      end
    end

end
