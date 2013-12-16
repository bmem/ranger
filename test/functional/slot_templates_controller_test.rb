require 'test_helper'

class SlotTemplatesControllerTest < ActionController::TestCase
  setup do
    sign_in users(:adminuser)
    @slot_template = slot_templates(:one)
    @shift_template = @slot_template.shift_template
  end

  test "should get index" do
    get :index, shift_template_id: @shift_template.id
    assert_response :success
    assert_not_nil assigns(:slot_templates)
  end

  test "should get new" do
    get :new, shift_template_id: @shift_template.id
    assert_response :success
  end

  test "should create slot_template" do
    assert_difference('SlotTemplate.count') do
      post :create, slot_template: {
        shift_template_id: @shift_template.id,
        position_id: positions(:alpha).id,
        max_people: @slot_template.max_people,
        min_people: @slot_template.min_people },
        shift_template_id: @shift_template.id
      puts assigns(:slot_template).errors.full_messages
    end

    assert_redirected_to shift_template_path(assigns(:shift_template))
  end

  test "should show slot_template" do
    get :show, id: @slot_template, shift_template_id: @shift_template.id
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @slot_template, shift_template_id: @shift_template.id
    assert_response :success
  end

  test "should update slot_template" do
    put :update, id: @slot_template, slot_template: {
      shift_template_id: @shift_template.id,
      max_people: @slot_template.max_people,
      min_people: @slot_template.min_people },
      shift_template_id: @shift_template.id
    assert_redirected_to shift_template_slot_template_path(assigns(:shift_template), assigns(:slot_template))
  end

  test "should destroy slot_template" do
    assert_difference('SlotTemplate.count', -1) do
      delete :destroy, id: @slot_template, shift_template_id: @shift_template.id
    end

    assert_redirected_to shift_template_slot_templates_path(assigns(:shift_template))
  end
end
