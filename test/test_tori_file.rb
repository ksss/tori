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
    def rewind
    end

    def read
      __FILE__
    end
  end

  test "#initialize" do
    assert_instance_of Tori::File, Tori::File.new(nil, nil)
    assert_instance_of Tori::File, Tori::File.new(nil, nil, from: nil)
    assert_instance_of Tori::File, Tori::File.new(nil, nil, from: nil) { }
  end

  test "#name" do
    assert { "test" == Tori::File.new("test", nil).name }
    assert { "String/test/sub" == Tori::File.new("test", nil){ |m| "#{m.class}/#{m}/sub"}.name }
  end

  test "#exist?" do
    assert { true == Tori::File.new(__FILE__, nil).exist? }
    assert { false == Tori::File.new("nothing_file", nil).exist? }
  end

  test "#from?" do
    assert { false == Tori::File.new(__FILE__, nil).from? }
    assert { true == Tori::File.new(__FILE__, nil, from: From.new).from? }
  end

  test "write" do
    assert { false == File.exist?("test/tmp/copy") }
    Tori::File.new("copy", nil, from: From.new).write
    assert { true == File.exist?("test/tmp/copy") }
  end

  test "write with closed file" do
    tori_file = nil
    path = nil
    Tempfile.create("tempfile") do |f|
      path = f.path
      f.write("should be match ;)")
      tori_file = Tori::File.new("tempfile", nil, from: f)
    end
    tori_file.write
    assert { true == File.exist?("test/tmp/tempfile") }
    assert { false == File.exist?(path) }
    assert { "should be match ;)" == File.read("test/tmp/tempfile") }
    assert { "should be match ;)" == tori_file.read }
  end

  test "#method_missing" do
    assert { true == Tori::File.new(nil, nil).respond_to?(:read) }
    assert_raise(NameError) { Tori::File.new(nil, nil).undefined }
  end
end
