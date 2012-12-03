require 'test_helper'

class ReasonableDateValidatorTest < ActiveModel::TestCase
  class DatedModel
    include ActiveModel::Validations
    include ActiveModel::Validations::Callbacks

    attr_accessor :some_date

    def initialize(attributes = {})
      attributes.each do |key, value|
        send "#{key}=", value
      end
    end
  end

  def teardown
    DatedModel.reset_callbacks(:validate)
  end

  test "defaults" do
    DatedModel.validates_with ReasonableDateValidator,
      :attributes => [:some_date]

    assert DatedModel.new(:some_date => Date.new(-2000, 6, 30)).invalid?
    assert DatedModel.new(:some_date => Date.new(123, 4, 5)).invalid?
    assert DatedModel.new(:some_date => Date.new(1000, 1, 1)).invalid?
    assert DatedModel.new(:some_date => Date.new(1776, 7, 4)).invalid?
    assert DatedModel.new(:some_date => Date.new(1899, 12, 31)).invalid?
    assert DatedModel.new(:some_date => Date.new(1900, 1, 1)).valid?
    assert DatedModel.new(:some_date => Date.new(1999, 10, 31)).valid?
    assert DatedModel.new(:some_date => Date.yesterday).valid?
    assert DatedModel.new(:some_date => Date.current).valid?
    assert DatedModel.new(:some_date => Date.tomorrow).valid?
    assert DatedModel.new(:some_date => Date.current.next_year).valid?
    assert DatedModel.new(:some_date => 50.years.from_now).valid?
    assert DatedModel.new(:some_date => 51.years.from_now).invalid?
    assert DatedModel.new(:some_date => 100.years.from_now).invalid?
    assert DatedModel.new(:some_date => Date.new(9876, 12, 31)).invalid?
    assert DatedModel.new(:some_date => Date.new(9999, 12, 31)).invalid?
    assert DatedModel.new(:some_date => Date.new(123456, 7, 8)).invalid?

    assert DatedModel.new(:some_date => DateTime.now).valid?
    assert DatedModel.new(:some_date => Time.now).valid?
    assert DatedModel.new(:some_date => Time.at(0)).valid?
    assert DatedModel.new(:some_date => Date.today.to_s).valid?
    assert DatedModel.new(:some_date => DateTime.now.to_s).valid?
    assert DatedModel.new(:some_date => '2012-12-12').valid?
  end

  test "disallow past" do
    DatedModel.validates_with ReasonableDateValidator, :allow_past => false,
      :attributes => [:some_date]

    assert DatedModel.new(:some_date => Date.new(1999, 10, 31)).invalid?
    assert DatedModel.new(:some_date => Date.yesterday).invalid?
    assert DatedModel.new(:some_date => Date.current).valid?
    assert DatedModel.new(:some_date => Date.tomorrow).valid?
    assert DatedModel.new(:some_date => Date.current.next_year).valid?
  end

  test "disallow future" do
    DatedModel.validates_with ReasonableDateValidator, :allow_future => false,
      :attributes => [:some_date]

    assert DatedModel.new(:some_date => Date.new(1999, 10, 31)).valid?
    assert DatedModel.new(:some_date => Date.yesterday).valid?
    assert DatedModel.new(:some_date => Date.current).valid?
    assert DatedModel.new(:some_date => Date.tomorrow).invalid?
    assert DatedModel.new(:some_date => Date.current.next_year).invalid?
  end

  test "recent min year" do
    DatedModel.validates_with ReasonableDateValidator, :min_year => 2010,
      :attributes => [:some_date]

    assert DatedModel.new(:some_date => Date.new(2009, 9, 9)).invalid?
    assert DatedModel.new(:some_date => Date.new(2009, 12, 31)).invalid?
    assert DatedModel.new(:some_date => Date.new(2010, 1, 1)).valid?
    assert DatedModel.new(:some_date => Date.new(2011, 10, 31)).valid?
    assert DatedModel.new(:some_date => Date.yesterday).valid?
    assert DatedModel.new(:some_date => Date.current).valid?
    assert DatedModel.new(:some_date => Date.tomorrow).valid?
    assert DatedModel.new(:some_date => Date.current.next_year).valid?
  end

  test "distant min year" do
    DatedModel.validates_with ReasonableDateValidator, :min_year => 100,
      :attributes => [:some_date]

    assert DatedModel.new(:some_date => Date.new(42, 4, 2)).invalid?
    assert DatedModel.new(:some_date => Date.new(99, 12, 31)).invalid?
    assert DatedModel.new(:some_date => Date.new(100, 1, 1)).valid?
    assert DatedModel.new(:some_date => Date.new(1234, 5, 6)).valid?
    assert DatedModel.new(:some_date => Date.new(2011, 10, 31)).valid?
    assert DatedModel.new(:some_date => Date.yesterday).valid?
    assert DatedModel.new(:some_date => Date.current).valid?
    assert DatedModel.new(:some_date => Date.tomorrow).valid?
    assert DatedModel.new(:some_date => Date.current.next_year).valid?
  end

  test "recent max year" do
    DatedModel.validates_with ReasonableDateValidator, :max_year => 2010,
      :attributes => [:some_date]

    assert DatedModel.new(:some_date => Date.new(1999, 9, 9)).valid?
    assert DatedModel.new(:some_date => Date.new(1999, 12, 31)).valid?
    assert DatedModel.new(:some_date => Date.new(2010, 1, 1)).valid?
    assert DatedModel.new(:some_date => Date.new(2010, 12, 31)).valid?
    assert DatedModel.new(:some_date => Date.new(2011, 1, 1)).invalid?
    assert DatedModel.new(:some_date => Date.new(2011, 10, 31)).invalid?
    assert DatedModel.new(:some_date => Date.yesterday).invalid?
    assert DatedModel.new(:some_date => Date.current).invalid?
    assert DatedModel.new(:some_date => Date.tomorrow).invalid?
    assert DatedModel.new(:some_date => Date.current.next_year).invalid?
    assert DatedModel.new(:some_date => 200.years.from_now).invalid?
  end

  test "distant max year" do
    DatedModel.validates_with ReasonableDateValidator,
      :max_year => 1000.years.from_now.year, :attributes => [:some_date]

    assert DatedModel.new(:some_date => Date.new(2042, 4, 2)).valid?
    assert DatedModel.new(:some_date => Date.new(1999, 12, 31)).valid?
    assert DatedModel.new(:some_date => Date.new(2011, 10, 31)).valid?
    assert DatedModel.new(:some_date => Date.yesterday).valid?
    assert DatedModel.new(:some_date => Date.current).valid?
    assert DatedModel.new(:some_date => Date.tomorrow).valid?
    assert DatedModel.new(:some_date => Date.current.next_year).valid?
    assert DatedModel.new(:some_date => 50.years.from_now).valid?
    assert DatedModel.new(:some_date => 150.years.from_now).valid?
    assert DatedModel.new(:some_date => 1001.years.from_now).invalid?
    assert DatedModel.new(:some_date => 4321.years.from_now).invalid?
  end
end
