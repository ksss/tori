require 'test_helper'

class TestToriDefine < Test::Unit::TestCase
  class CustomBackend
    def read(filename)
      "read:#{filename}"
    end
  end

  class Dammy
    extend Tori::Define
    tori :test_image
    bird = "piyo"
    tori :def_image do |model|
      "foo/#{__tori__}/bar/#{bird}"
    end
    tori :custom, to: CustomBackend.new do |model|
      "#{__tori__}/baz"
    end
  end

  class Uploader
  end

  test "#tori" do
    assert_respond_to Dammy.new, :test_image
    assert_respond_to Dammy.new, :test_image=
    assert_respond_to Dammy.new, :def_image
    assert_respond_to Dammy.new, :def_image=
    assert_respond_to Dammy.new, :custom
    assert_respond_to Dammy.new, :custom=
  end

  test "defined methods" do
    dammy = Dammy.new
    assert_instance_of Tori::File, dammy.test_image
    assert_instance_of Uploader, dammy.test_image = Uploader.new
    assert_instance_of Tori::File, dammy.test_image
    assert_instance_of Tori::Backend::FileSystem, dammy.test_image.backend
    assert_instance_of CustomBackend, dammy.custom.backend
  end

  test "defined method" do
    dammy = Dammy.new
    assert { false == dammy.def_image.exist? }
    assert { "read:custom/baz" == dammy.custom.read }
  end

  test "define name" do
    dammy = Dammy.new
    assert_instance_of Tori::File, dammy.def_image
    assert { "foo/def_image/bar/piyo" == dammy.def_image.name }
    assert { "custom/baz" == dammy.custom.name }
  end
end
