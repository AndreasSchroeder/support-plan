require 'test_helper'

class SemesterBreakPlansControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get semester_break_plans_index_url
    assert_response :success
  end

  test "should get show" do
    get semester_break_plans_show_url
    assert_response :success
  end

end
