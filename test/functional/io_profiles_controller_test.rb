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

  test "should create io_profiles" do
    assert_difference('IoProfiles.count') do
      post :create, :io_profiles => { }
    end

    assert_redirected_to io_profiles_path(assigns(:io_profiles))
  end

  test "should show io_profiles" do
    get :show, :id => io_profiles(:one).id
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => io_profiles(:one).id
    assert_response :success
  end

  test "should update io_profiles" do
    put :update, :id => io_profiles(:one).id, :io_profiles => { }
    assert_redirected_to io_profiles_path(assigns(:io_profiles))
  end

  test "should destroy io_profiles" do
    assert_difference('IoProfiles.count', -1) do
      delete :destroy, :id => io_profiles(:one).id
    end

    assert_redirected_to io_profiles_path
  end
end
