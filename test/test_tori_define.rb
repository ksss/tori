require 'test_helper'

class TestToriDefine < Test::Unit::TestCase
  class Dammy
    extend Tori::Define
    tori :test_image
  end

  test "#tori" do
    assert_respond_to Dammy.new, :test_image
    assert_respond_to Dammy.new, :test_image=
  end
end
