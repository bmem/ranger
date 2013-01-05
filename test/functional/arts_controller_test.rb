require 'test_helper'

class ArtsControllerTest < ActionController::TestCase
  setup do
    sign_in users(:adminuser)
    @art = arts(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:arts)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create art" do
    assert_difference('Art.count') do
      post :create, :art => { :description => @art.description, :name => "New #{@art.name}", :prerequisite => @art.prerequisite }
    end

    assert_redirected_to art_path(assigns(:art))
  end

  test "should show art" do
    get :show, :id => @art
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => @art
    assert_response :success
  end

  test "should update art" do
    put :update, :id => @art, :art => { :description => @art.description, :name => "New #{@art.name}", :prerequisite => @art.prerequisite }
    assert_redirected_to art_path(assigns(:art))
  end

  test "should destroy art" do
    assert_difference('Art.count', -1) do
      delete :destroy, :id => @art
    end

    assert_redirected_to arts_path
  end
end
