require 'test_helper'

class PeopleControllerTest < ActionController::TestCase
  setup do
    sign_in users(:adminuser)
    @person = people(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:people)
  end

  test "should get search" do
    Person.build_index
    person = people(:able_baker)
    get :search, q: person.display_name
    assert_response :success
    results = assigns(:people)
    assert_not_nil results
    assert results.length > 0, "empty search result"
    assert person.in?(results), "#{results} missing #{person}"
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create person" do
    assert_difference('Person.count') do
      attrs = {full_name: 'Test Person Create', status: 'prospective'}
      post :create, :person => attrs
    end

    assert_redirected_to person_path(assigns(:person))
  end

  test "should show person" do
    get :show, :id => @person
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => @person
    assert_response :success
  end

  test "should update person" do
    put :update, id: @person, person: {display_name: @person.display_name, full_name: @person.full_name, email: @person.email, status: @person.status, barcode: @person.barcode}
    assert_redirected_to person_path(assigns(:person))
  end

  test "should destroy person" do
    assert_difference('Person.count', -1) do
      delete :destroy, :id => @person
    end

    assert_redirected_to people_path
  end
end
