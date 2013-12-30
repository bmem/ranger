require 'test_helper'

class InvolvementsControllerTest < ActionController::TestCase
  setup do
    sign_in users(:adminuser)
    @involvement = involvements(:e1p1)
  end

  test "should get index" do
    get :index, event_id: @involvement.event_id
    assert_response :success
    assert_not_nil assigns(:involvements)
    assert assigns(:involvements).include? @involvement
  end

  test "should get new" do
    get :new, event_id: @involvement.event_id, person_id: @involvement.person.id
    assert_response :success
  end

  test "should create involvement" do
    assert_difference('Involvement.count') do
      post :create, event_id: @involvement.event_id, person_id: people(:alpha1).id, involvement: { involvement_status: 'planned', personnel_status: 'alpha', on_site: false }
    end

    assert_redirected_to event_involvement_path(@involvement.event, assigns(:involvement))
  end

  test "should show involvement" do
    get :show, event_id: @involvement.event_id, id: @involvement
    assert_response :success
  end

  test "should get edit" do
    get :edit, event_id: @involvement.event_id, id: @involvement
    assert_response :success
  end

  test "should update involvement" do
    put :update, event_id: @involvement.event_id, id: @involvement, involvement: { personnel_status: @involvement.personnel_status, involvement_status: @involvement.involvement_status }
    assert_redirected_to event_involvement_path(@involvement.event, assigns(:involvement))
  end

  test "should destroy involvement" do
    assert_difference('Involvement.count', -1) do
      delete :destroy, event_id: @involvement.event_id, id: @involvement
    end

    assert_redirected_to event_involvements_path(@involvement.event)
  end
end
