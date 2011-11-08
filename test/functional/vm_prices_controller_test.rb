require 'test_helper'

class VmPricesControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:vm_prices)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create vm_price" do
    assert_difference('VmPrice.count') do
      post :create, :vm_price => { }
    end

    assert_redirected_to vm_price_path(assigns(:vm_price))
  end

  test "should show vm_price" do
    get :show, :id => vm_prices(:one).id
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => vm_prices(:one).id
    assert_response :success
  end

  test "should update vm_price" do
    put :update, :id => vm_prices(:one).id, :vm_price => { }
    assert_redirected_to vm_price_path(assigns(:vm_price))
  end

  test "should destroy vm_price" do
    assert_difference('VmPrice.count', -1) do
      delete :destroy, :id => vm_prices(:one).id
    end

    assert_redirected_to vm_prices_path
  end
end
