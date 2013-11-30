require 'test_helper'

class StringExtensionsTest < ActiveSupport::TestCase
  test "to_tokens handles blank" do
    assert_equal [], ''.to_tokens
    assert_equal [], '   '.to_tokens
  end

  test "to_tokens on a single word gets one token" do
    assert_equal %w(test), 'test'.to_tokens
    assert_equal %w(Hello), '  Hello '.to_tokens
  end

  test "to_tokens turns words to tokens" do
    assert_equal %w(testing 123), 'testing 123'.to_tokens
    assert_equal %w(Hello World), '  Hello   World '.to_tokens
    assert_equal %w(my hovercraft is full of eels), 'my hovercraft is full of eels'.to_tokens
  end

  test "to_tokens strips leading and trailing punctuation" do
    assert_equal %w(testing 123), 'testing, 123.'.to_tokens
    assert_equal %w(Hello World), 'Hello, World!'.to_tokens
    assert_equal %w(Dan The Man Japan), 'Dan "The Man" Japan'.to_tokens
  end

  test "to_tokens creates two versions of words with internal punctuation" do
    assert_equal %w(Paddy O'Furniture OFurniture), "Paddy O'Furniture".to_tokens
    assert_equal %w(Strunk/White slash-fiction StrunkWhite slashfiction), 'Strunk/White slash-fiction'.to_tokens
    assert_equal %w(black&tan blacktan), 'black&tan'.to_tokens
  end

  test "to_tokens spilts camel case" do
    assert_equal %w(CamelCase camel case), 'CamelCase'.to_tokens
    assert_equal %w(the NSA is watching), 'the NSA is watching'.to_tokens
    assert_equal %w(Middle ofThe Day of the), 'Middle ofThe Day'.to_tokens
  end

  test "to_tokens splits out numbers" do
    assert_equal %w(testing123 testing 123), 'testing123'.to_tokens
    assert_equal %w(Hello 2ndWorld 2 nd world), 'Hello, 2ndWorld!'.to_tokens
    assert_equal %w(SmithJ13B smith j 13 b), 'SmithJ13B'.to_tokens
    assert_equal %w(back2back back 2), 'back2back'.to_tokens
  end
end
