require 'test_helper'

class AssetUsesControllerTest < ActionController::TestCase
  setup do
    sign_in users(:adminuser)
    @asset_use = asset_uses(:one)
    @event = @asset_use.event
  end

  test "should get index" do
    get :index, event_id: @event.id
    assert_response :success
    assert_not_nil assigns(:asset_uses)
  end

  test "should get new" do
    get :new, event_id: @event.id
    assert_response :success
  end

  test "should create asset_use" do
    assert_difference('AssetUse.count') do
      post :create, event_id: @event.id, asset_use: { asset_id: @asset_use.asset.id, involvement_id: @asset_use.involvement.id, checked_in: Time.zone.now, checked_out: @asset_use.checked_out, due_in: @asset_use.due_in, extra: @asset_use.extra, note: @asset_use.note }
    end

    assert_redirected_to event_asset_use_path(assigns(:event), assigns(:asset_use))
  end

  test "should show asset_use" do
    get :show, event_id: @event.id, id: @asset_use
    assert_response :success
  end

  test "should get edit" do
    get :edit, event_id: @event.id, id: @asset_use
    assert_response :success
  end

  test "should update asset_use" do
    put :update, event_id: @event.id, id: @asset_use, asset_use: { checked_in: @asset_use.checked_in, checked_out: @asset_use.checked_out, due_in: @asset_use.due_in, extra: @asset_use.extra, note: @asset_use.note }
    assert_redirected_to event_asset_use_path(assigns(:event), assigns(:asset_use))
  end

  test "should destroy asset_use" do
    assert_difference('AssetUse.count', -1) do
      delete :destroy, event_id: @event.id, id: @asset_use
    end

    assert_redirected_to event_asset_uses_path(@event.id)
  end
end
