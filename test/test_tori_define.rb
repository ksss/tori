require 'test_helper'

class TestToriDefine < Test::Unit::TestCase
  class Dammy
    extend Tori::Define
    tori :test_image
  end

  class Uploader
  end

  test "#tori" do
    assert_respond_to Dammy.new, :test_image
    assert_respond_to Dammy.new, :test_image=
  end

  test "defined methods" do
    assert_instance_of Uploader, Dammy.new.test_image = Uploader.new
    assert_instance_of Tori::File, Dammy.new.test_image
  end
end
