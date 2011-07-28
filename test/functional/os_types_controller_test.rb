require 'test_helper'

class OsTypesControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:os_types)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create os_type" do
    assert_difference('OsType.count') do
      post :create, :os_type => { }
    end

    assert_redirected_to os_type_path(assigns(:os_type))
  end

  test "should show os_type" do
    get :show, :id => os_types(:one).id
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => os_types(:one).id
    assert_response :success
  end

  test "should update os_type" do
    put :update, :id => os_types(:one).id, :os_type => { }
    assert_redirected_to os_type_path(assigns(:os_type))
  end

  test "should destroy os_type" do
    assert_difference('OsType.count', -1) do
      delete :destroy, :id => os_types(:one).id
    end

    assert_redirected_to os_types_path
  end
end
