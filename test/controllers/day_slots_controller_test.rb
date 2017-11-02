require 'test_helper'

class DaySlotsControllerTest < ActionDispatch::IntegrationTest
  test "should get destroy" do
    get day_slots_destroy_url
    assert_response :success
  end

end
