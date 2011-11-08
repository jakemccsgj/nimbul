require 'test_helper'

class IoProfilesControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:io_profiles)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create io_profile" do
    assert_difference('IoProfile.count') do
      post :create, :io_profile => { }
    end

    assert_redirected_to io_profile_path(assigns(:io_profile))
  end

  test "should show io_profile" do
    get :show, :id => io_profiles(:one).id
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => io_profiles(:one).id
    assert_response :success
  end

  test "should update io_profile" do
    put :update, :id => io_profiles(:one).id, :io_profile => { }
    assert_redirected_to io_profile_path(assigns(:io_profile))
  end

  test "should destroy io_profile" do
    assert_difference('IoProfile.count', -1) do
      delete :destroy, :id => io_profiles(:one).id
    end

    assert_redirected_to io_profiles_path
  end
end
