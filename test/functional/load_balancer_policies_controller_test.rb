require 'test_helper'

class LoadBalancerPoliciesControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:load_balancer_policies)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create load_balancer_policy" do
    assert_difference('LoadBalancerPolicy.count') do
      post :create, :load_balancer_policy => { }
    end

    assert_redirected_to load_balancer_policy_path(assigns(:load_balancer_policy))
  end

  test "should show load_balancer_policy" do
    get :show, :id => load_balancer_policies(:one).id
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => load_balancer_policies(:one).id
    assert_response :success
  end

  test "should update load_balancer_policy" do
    put :update, :id => load_balancer_policies(:one).id, :load_balancer_policy => { }
    assert_redirected_to load_balancer_policy_path(assigns(:load_balancer_policy))
  end

  test "should destroy load_balancer_policy" do
    assert_difference('LoadBalancerPolicy.count', -1) do
      delete :destroy, :id => load_balancer_policies(:one).id
    end

    assert_redirected_to load_balancer_policies_path
  end
end
