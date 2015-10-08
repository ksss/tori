require 'test_helper'

class TestToriDefine < Test::Unit::TestCase
  class Dammy
    extend Tori::Define
    tori :test_image
    bird = "piyo"
    tori :def_image do |model|
      "foo/#{__tori__}/bar/#{bird}"
    end
  end

  class Uploader
  end

  test "#tori" do
    assert_respond_to Dammy.new, :test_image
    assert_respond_to Dammy.new, :test_image=
    assert_respond_to Dammy.new, :def_image
    assert_respond_to Dammy.new, :def_image=
  end

  test "defined methods" do
    dammy = Dammy.new
    assert_instance_of Tori::File, dammy.test_image
    assert_instance_of Uploader, dammy.test_image = Uploader.new
    assert_instance_of Tori::File, dammy.test_image
  end

  test "define name" do
    dammy = Dammy.new
    assert_instance_of Tori::File, dammy.def_image
    assert { "foo/def_image/bar/piyo" == dammy.def_image.name }
  end
end
