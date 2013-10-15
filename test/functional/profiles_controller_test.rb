require 'test_helper'

class ProfilesControllerTest < ActionController::TestCase
  setup do
    sign_in(:adminuser)
    @profile = profiles(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:profiles)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  # TODO make sure there's a way to create a profile for a person who doesn't have one yet
  #test "should create profile" do
  #  assert_difference('Profile.count') do
  #    post :create, profile: { birth_date: @profile.birth_date, contact_note: @profile.contact_note, email: 'profiletest@example.com', full_name: 'Profile Test', gender: @profile.gender, nicknames: @profile.nicknames, phone_numbers: @profile.phone_numbers, shirt_size: @profile.shirt_size, shirt_style: @profile.shirt_style, years_at_burning_man: @profile.years_at_burning_man }
  #  end
  #
  #  assert_redirected_to profile_path(assigns(:profile))
  #end

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
    assert_redirected_to profile_path(assigns(:profile))
  end

  test "should destroy profile" do
    assert_difference('Profile.count', -1) do
      delete :destroy, id: @profile
    end

    assert_redirected_to profiles_path
  end
end
