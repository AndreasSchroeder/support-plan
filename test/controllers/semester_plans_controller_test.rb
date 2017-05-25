require 'test_helper'

class SemesterPlansControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get semester_plans_index_url
    assert_response :success
  end

  test "should get show" do
    get semester_plans_show_url
    assert_response :success
  end

end
