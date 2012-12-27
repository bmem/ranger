require 'test_helper'

class TrainingsControllerTest < ActionController::TestCase
  setup do
    sign_in users(:adminuser)
    @training = trainings(:one)
    @event = @training.training_season
  end

  test "should get index" do
    get :index, event_id: @event.id
    assert_response :success
    assert_not_nil assigns(:trainings)
  end

  test "should get new" do
    get :new, event_id: @event.id
    assert_response :success
  end

  test "should create training" do
    assert_difference('Training.count') do
      post :create, event_id: @event.id, training: { instructions: @training.instructions, location: @training.location, map_link: @training.map_link, name: @training.name, shift_attributes: { start_time: @training.shift.start_time, end_time: @training.shift.end_time, description: 'Test training shift' } }
    end

    assert_redirected_to event_training_path(assigns(:event), assigns(:training))
  end

  test "should show training" do
    get :show, id: @training, event_id: @event.id
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @training, event_id: @event.id
    assert_response :success
  end

  test "should update training" do
    put :update, id: @training, event_id: @event.id, training: { instructions: @training.instructions, location: @training.location, map_link: @training.map_link, name: @training.name }
    assert_redirected_to event_training_path(assigns(:event), assigns(:training))
  end

  test "should destroy training" do
    assert_difference('Training.count', -1) do
      delete :destroy, id: @training, event_id: @event.id
    end

    assert_redirected_to event_trainings_path(assigns(:event))
  end
end
