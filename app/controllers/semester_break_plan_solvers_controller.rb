class SemesterBreakPlanSolversController < ApplicationController
  before_action :admin_user, only: [:solve, :update]
  before_action :set_plan, only: [:solve, :show, :update, :fix, :fixed, :delete_solution]

  def show
    @sol = eval(@plan.solution)
    @type = 0
  end

  def solve
    @plan.solve(params[:type].to_i)
    redirect_to action: 'show'
  end

  def update
    is_sol = params["semester_break_plan"].detect{|key, value| key == "type" && value.to_i == 0}
    if is_sol
      @sol = eval(@plan.solution)
    else
      @sol = eval(@plan.fixed_solution)
    end
    params["semester_break_plan"].each do |key, value|
      if key != "type"
        @sol.detect{|d| d[:slot].to_i == key.to_i}[:user] = value
      end
    end
    flash[:success] = "Gespeichert."
    if is_sol
      @plan.update(solution: "#{@sol}")
      redirect_to action: 'show'
    else
      @plan.update(fixed_solution: "#{@sol}")
      redirect_to action: 'fixed'
    end
  end

  def fix
    @plan.update(fixed_solution: @plan.solution)
    flash[:success] = "Gespeichert."
    redirect_to action: 'fixed'
  end

  def fixed
    if @plan.fixed_solution
      @sol = eval(@plan.fixed_solution)
    else
      @sol = @plan.empty_solution true
      p "#{@sol}"
      @plan.update(fixed_solution: "#{@sol}")
    end
    @type = 1
  end

  def delete_solution
    @plan.update(fixed_solution: nil)
    flash[:success] = "Gespeicherte Lösung gelöscht."
    redirect_to action: 'fixed'
  end

  private
   	# Confirms an admin user.
    def admin_user
      unless current_user.is_admin?
        flash[:danger] = "Keine Berechtigung."
        redirect_to(root_url)
      end
    end

    def set_plan
      @plan = SemesterBreakPlan.find(params[:id])

    end
end
