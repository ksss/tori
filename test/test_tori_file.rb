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
    assert_instance_of Tori::File, Tori::File.new(nil)
    assert_instance_of Tori::File, Tori::File.new(nil, from: nil)
    assert_instance_of Tori::File, Tori::File.new(nil, title: nil)
    assert_instance_of Tori::File, Tori::File.new(nil, from: nil) { }
    assert_raise(ArgumentError) { Tori::File.new }
    assert_raise(ArgumentError) { Tori::File.new(nil, nothing: nil) }
  end

  test "#name" do
    assert { "test" == Tori::File.new("test").name }
    assert { "String/test/sub" == Tori::File.new("test"){ |m| "#{m.class}/#{m}/sub"}.name }
  end

  test "#exist?" do
    assert { true == Tori::File.new(__FILE__).exist? }
    assert { false == Tori::File.new("nothing_file").exist? }
  end

  test "#from" do
    assert { __FILE__ == Tori::File.new(__FILE__, from: From.new).from }
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

  test "write with closed file" do
    tori_file = nil
    path = nil
    Tempfile.create("tempfile") do |f|
      path = f.path
      f.write("should be match ;)")
      tori_file = Tori::File.new("tempfile", from: f)
    end
    tori_file.write
    assert { true == File.exist?("test/tmp/tempfile") }
    assert { false == File.exist?(path) }
    assert { "should be match ;)" == File.read("test/tmp/tempfile") }
    assert { "should be match ;)" == tori_file.read }
  end

  test "with title" do
    before = Tori.config.filename_callback
    Tori.config.filename_callback do |model|
      "#{model}/#{__tori__}"
    end
    assert { "test/" == Tori::File.new("test").name }
    assert { "test/tori" == Tori::File.new("test", title: "tori").name }
    Tori.config.filename_callback &before
  end

  test "#method_missing" do
    assert { true == Tori::File.new(nil).respond_to?(:read) }
    assert_raise(NameError) { Tori::File.new(nil).undefined }
    assert { [true, Encoding.find('utf-8'), 'test/tmp'] == Tori::File.new(nil).open('rb', external_encoding: 'utf-8'){ |f| [f.binmode?, f.external_encoding, f.path] } }
  end
end
