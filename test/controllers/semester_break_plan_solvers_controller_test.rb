require 'test_helper'

class SemesterBreakPlanSolversControllerTest < ActionDispatch::IntegrationTest
  test "should get solve" do
    get semester_break_plan_solvers_solve_url
    assert_response :success
  end

end
