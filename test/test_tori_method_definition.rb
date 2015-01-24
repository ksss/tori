require 'test_helper'

class TestToriDefine < Test::Unit::TestCase
  class Dammy
    extend Tori::Define
    tori :test_image
    def id
      "dammy"
    end
  end

  test "#tori" do
    assert_respond_to Dammy.new, :test_image
    assert_respond_to Dammy.new, :test_image=
    assert_respond_to Dammy.new, :test_image_hash
  end
end
