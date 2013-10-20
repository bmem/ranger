require 'test_helper'

class ProfilesControllerTest < ActionController::TestCase
  setup do
    sign_in users(:adminuser)
    @profile = profiles(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:profiles)
  end

  test "should show profile" do
    get :show, id: @profile
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @profile
    assert_response :success
  end

  test "should update profile" do
    put :update, id: @profile, profile: { birth_date: @profile.birth_date, contact_note: @profile.contact_note, email: @profile.email, full_name: @profile.full_name, gender: @profile.gender, nicknames: @profile.nicknames, phone_numbers: @profile.phone_numbers, shirt_size: @profile.shirt_size, shirt_style: @profile.shirt_style, years_at_burning_man: @profile.years_at_burning_man }
    assert_redirected_to person_path(@profile.person)
  end
end
