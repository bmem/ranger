require 'test_helper'

class PersonTest < ActiveSupport::TestCase
  test "name is required" do
    assert_valid Person.new :display_name => 'Blue Eyes', :full_name => 'Frank Sinatra'
    assert Person.new.invalid?, "Empty Person was valid"
    assert Person.new(:display_name => 'Ishmael').invalid?, "Person without full_name was valid"
    # Default display_name is same as full_name
    p = Person.new(full_name: 'Ford Prefect', status: 'active')
    p.update_display_name!
    assert_valid p
    assert_present p.display_name, "Blank default display_name"
  end

  test "display_name is unique" do
    p1 = Person.new :display_name => 'Highlander', :full_name => 'Highlander'
    assert_valid p1
    assert p1.save
    p2 = Person.new :display_name => 'Highlander', :full_name => 'Highlander'
    assert p2.invalid?, "Duplicate display_name allowed"
  end

  test "empty email is allowed" do
    p = Person.new :display_name => 'Blue Eyes', :full_name => 'Frank Sinatra'
    assert_valid p
    p.email = ''
    assert_valid p
  end

  test "email is unique" do
    p1 = Person.new :display_name => 'EDude', :full_name => 'Email Dude', :email => 'myemail@example.com'
    assert_valid p1
    assert p1.save, "Could not create #{p1}"
    p2 = Person.new :display_name => 'EChick', :full_name => 'Email Chick', :email => 'myemail@example.com'
    assert !p2.valid?, "Duplicate email was valid"
    p3 = Person.new :display_name => 'UCDude', :full_name => 'Upper Case Dude', :email => 'MYEMAIL@EXAMPLE.COM'
    assert !p3.valid?, "Upper case duplicate email was valid"
  end

  test "find by email" do
    p1 = Person.new :email => 'fbe@example.com', :display_name => 'FindByEmail', :full_name => 'Find Me'
    assert p1.save
    assert p1 == Person.find_by_email(p1.email).first, "Didn't find #{p1.email}"
    assert p1 == Person.find_by_email(p1.email.upcase).first, "Didn't find #{p1.email.upcase}" end

  # TODO Fixtures do direct SQL insertion so don't go through details store :-(
  #test "details store" do
  #  able_baker = people(:able_baker)
  #  assert_equal 'L', able_baker.shirt_size
  #  assert_equal '205-555-2253', able_baker.main_phone
  #  assert_equal Time.zone.local(1946, 4, 8), able_baker.birth_date
  #end
end
