require 'test_helper'

class AssetsControllerTest < ActionController::TestCase
  setup do
    sign_in users(:adminuser)
    @asset = assets(:one)
  end

  test "should get index" do
    get :index, event_id: @asset.event_id
    assert_response :success
    assert_not_nil assigns(:assets)
  end

  test "should get new" do
    get :new, event_id: @asset.event_id
    assert_response :success
  end

  test "should get new with type" do
    get :new, event_id: @asset.event_id, type: 'Radio'
    assert_response :success
    assert_equal Radio, assigns(:asset).class
  end

  test "should create asset" do
    assert_difference('Asset.count') do
      post :create, event_id: @asset.event_id, asset: { description: @asset.description, designation: @asset.designation, name: "Should-Create-Asset", type: @asset.type }
    end

    assert_redirected_to event_asset_path(assigns(:event), assigns(:asset))
  end

  test "should show asset" do
    get :show, event_id: @asset.event_id, id: @asset
    assert_response :success
  end

  test "should get edit" do
    get :edit, event_id: @asset.event_id, id: @asset
    assert_response :success
  end

  test "should update asset" do
    put :update, event_id: @asset.event_id, id: @asset, asset: { description: @asset.description, designation: @asset.designation, name: @asset.name, type: @asset.type }
    assert_redirected_to event_asset_path(assigns(:event), assigns(:asset))
  end

  test "should destroy asset" do
    assert_difference('Asset.count', -1) do
      delete :destroy, event_id: @asset.event, id: @asset
    end

    assert_redirected_to event_assets_path(@asset.event)
  end
end
