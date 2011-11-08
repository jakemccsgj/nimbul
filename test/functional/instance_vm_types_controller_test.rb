require 'test_helper'

class InstanceVmTypesControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:instance_vm_types)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create instance_vm_type" do
    assert_difference('InstanceVmType.count') do
      post :create, :instance_vm_type => { }
    end

    assert_redirected_to instance_vm_type_path(assigns(:instance_vm_type))
  end

  test "should show instance_vm_type" do
    get :show, :id => instance_vm_types(:one).id
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => instance_vm_types(:one).id
    assert_response :success
  end

  test "should update instance_vm_type" do
    put :update, :id => instance_vm_types(:one).id, :instance_vm_type => { }
    assert_redirected_to instance_vm_type_path(assigns(:instance_vm_type))
  end

  test "should destroy instance_vm_type" do
    assert_difference('InstanceVmType.count', -1) do
      delete :destroy, :id => instance_vm_types(:one).id
    end

    assert_redirected_to instance_vm_types_path
  end
end
