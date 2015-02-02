require 'test_helper'

class TestToriDefine < Test::Unit::TestCase
  setup do
    @orig = Tori.config.filename_callback
    Tori.config.filename_callback do |model|
      model
    end
    Tori.config.backend = Tori::Backend::FileSystem.new Pathname("test").join("tmp")
  end

  teardown do
    Tori.config.filename_callback &@orig
    FileUtils.rm_rf("test/tmp")
  end

  class From
    def path
      __FILE__
    end
  end

  test "#initialize" do
    assert_instance_of Tori::File, Tori::File.new(nil)
    assert_instance_of Tori::File, Tori::File.new(nil, from: nil)
  end

  test "#name" do
    assert { "test" == Tori::File.new("test").name }
  end

  test "#exist?" do
    assert { true == Tori::File.new(__FILE__).exist? }
    assert { false == Tori::File.new("nothing_file").exist? }
  end

  test "#copy?" do
    assert { false == Tori::File.new(__FILE__).copy? }
    assert { true == Tori::File.new(__FILE__, from: From.new).copy? }
  end

  test "copy" do
    assert { false == File.exist?("test/tmp/copy") }
    Tori::File.new("copy", from: From.new).copy
    assert { true == File.exist?("test/tmp/copy") }
  end
end
