require 'test_helper'

class AssetTest < ActiveSupport::TestCase
  test "validates name uniqueness" do
    asset1 = Asset.new name: '42', type: Asset
    asset1.event = events(:one)
    assert asset1.valid?, "First asset was invalid " + asset1.errors.full_messages.to_sentence
    asset1.save!
    asset2 = Asset.new name: '42', type: Asset
    asset2.event = events(:two)
    assert asset2.valid?, "Asset with same name and different event was invalid"
    asset2.save!
    asset3 = Asset.new name: '42', type: Asset
    asset3.event = events(:one)
    assert asset3.invalid?, "Duplicate asset was valid"
  end
end
