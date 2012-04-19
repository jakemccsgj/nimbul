require 'test_helper'

class VmOsTypesControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:vm_os_types)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create vm_os_type" do
    assert_difference('VmOsType.count') do
      post :create, :vm_os_type => { }
    end

    assert_redirected_to vm_os_type_path(assigns(:vm_os_type))
  end

  test "should show vm_os_type" do
    get :show, :id => vm_os_types(:one).id
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => vm_os_types(:one).id
    assert_response :success
  end

  test "should update vm_os_type" do
    put :update, :id => vm_os_types(:one).id, :vm_os_type => { }
    assert_redirected_to vm_os_type_path(assigns(:vm_os_type))
  end

  test "should destroy vm_os_type" do
    assert_difference('VmOsType.count', -1) do
      delete :destroy, :id => vm_os_types(:one).id
    end

    assert_redirected_to vm_os_types_path
  end
end
