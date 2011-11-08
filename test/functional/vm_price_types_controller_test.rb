require 'test_helper'

class VmPriceTypesControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:vm_price_types)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create vm_price_type" do
    assert_difference('VmPriceType.count') do
      post :create, :vm_price_type => { }
    end

    assert_redirected_to vm_price_type_path(assigns(:vm_price_type))
  end

  test "should show vm_price_type" do
    get :show, :id => vm_price_types(:one).id
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => vm_price_types(:one).id
    assert_response :success
  end

  test "should update vm_price_type" do
    put :update, :id => vm_price_types(:one).id, :vm_price_type => { }
    assert_redirected_to vm_price_type_path(assigns(:vm_price_type))
  end

  test "should destroy vm_price_type" do
    assert_difference('VmPriceType.count', -1) do
      delete :destroy, :id => vm_price_types(:one).id
    end

    assert_redirected_to vm_price_types_path
  end
end
