require 'test_helper'

class TestToriFile < Test::Unit::TestCase
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
    assert_instance_of Tori::File, Tori::File.new(nil, from: nil) { }
  end

  test "#name" do
    assert { "test" == Tori::File.new("test").name }
    assert { "String/test/sub" == Tori::File.new("test"){ |m| "#{m.class}/#{m}/sub"}.name }
  end

  test "#exist?" do
    assert { true == Tori::File.new(__FILE__).exist? }
    assert { false == Tori::File.new("nothing_file").exist? }
  end

  test "#from?" do
    assert { false == Tori::File.new(__FILE__).from? }
    assert { true == Tori::File.new(__FILE__, from: From.new).from? }
  end

  test "write" do
    assert { false == File.exist?("test/tmp/copy") }
    Tori::File.new("copy", from: From.new).write
    assert { true == File.exist?("test/tmp/copy") }
  end

  test "#method_missing" do
    assert { true == Tori::File.new(nil).respond_to?(:read) }
    assert_raise(NameError) { Tori::File.new(nil).undefined }
  end
end
