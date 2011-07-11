require 'test_helper'

class CpuProfilesControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:cpu_profiles)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create cpu_profile" do
    assert_difference('CpuProfile.count') do
      post :create, :cpu_profile => { }
    end

    assert_redirected_to cpu_profile_path(assigns(:cpu_profile))
  end

  test "should show cpu_profile" do
    get :show, :id => cpu_profiles(:one).id
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => cpu_profiles(:one).id
    assert_response :success
  end

  test "should update cpu_profile" do
    put :update, :id => cpu_profiles(:one).id, :cpu_profile => { }
    assert_redirected_to cpu_profile_path(assigns(:cpu_profile))
  end

  test "should destroy cpu_profile" do
    assert_difference('CpuProfile.count', -1) do
      delete :destroy, :id => cpu_profiles(:one).id
    end

    assert_redirected_to cpu_profiles_path
  end
end
