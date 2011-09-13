require 'test_helper'

class HealthChecksControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:health_checks)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create health_check" do
    assert_difference('HealthCheck.count') do
      post :create, :health_check => { }
    end

    assert_redirected_to health_check_path(assigns(:health_check))
  end

  test "should show health_check" do
    get :show, :id => health_checks(:one).id
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => health_checks(:one).id
    assert_response :success
  end

  test "should update health_check" do
    put :update, :id => health_checks(:one).id, :health_check => { }
    assert_redirected_to health_check_path(assigns(:health_check))
  end

  test "should destroy health_check" do
    assert_difference('HealthCheck.count', -1) do
      delete :destroy, :id => health_checks(:one).id
    end

    assert_redirected_to health_checks_path
  end
end
