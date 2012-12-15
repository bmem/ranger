require 'test_helper'

class PersonTest < ActiveSupport::TestCase
  test "name is required" do
    assert_valid Person.new :callsign => 'Blue Eyes', :full_name => 'Frank Sinatra'
    assert Person.new.invalid?, "Empty Person was valid"
    assert Person.new(:callsign => 'Ishmael').invalid?, "Person without full_name was valid"
    # Default callsign is "Full Name (new YYYY)"
    p = Person.new(:full_name => 'Ford Prefect')
    assert_valid p
    assert_present p.callsign, "Blank default callsign"
  end

  test "callsign is unique" do
    p1 = Person.new :callsign => 'Highlander', :full_name => 'Only One'
    assert_valid p1
    assert p1.save
    p2 = Person.new :callsign => 'Highlander', :full_name => 'Imposter'
    assert p2.invalid?, "Duplicate callsign allowed"
  end

  test "empty email is allowed" do
    p = Person.new :callsign => 'Blue Eyes', :full_name => 'Frank Sinatra'
    assert_valid p
    p.email = ''
    assert_valid p
  end

  test "email is unique" do
    p1 = Person.new :callsign => 'EDude', :full_name => 'Email Dude', :email => 'myemail@example.com'
    assert_valid p1
    assert p1.save, "Could not create #{p1}"
    p2 = Person.new :callsign => 'EChick', :full_name => 'Email Chick', :email => 'myemail@example.com'
    assert !p2.valid?, "Duplicate email was valid"
    p3 = Person.new :callsign => 'UCDude', :full_name => 'Upper Case Dude', :email => 'MYEMAIL@EXAMPLE.COM'
    assert !p3.valid?, "Upper case duplicate email was valid"
  end

  test "find by email" do
    p1 = Person.new :email => 'fbe@example.com', :callsign => 'FindByEmail', :full_name => 'Find Me'
    assert p1.save
    assert p1 == Person.find_by_email(p1.email).first, "DIdn't find #{p1.email}"
    assert p1 == Person.find_by_email(p1.email.upcase).first, "DIdn't find #{p1.email.upcase}"
  end
end
