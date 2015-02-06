require 'test_helper'

class TestToriBackendFileSystem < Test::Unit::TestCase
  setup do
    path = Pathname("test/tmp/tori/store")
    @filesystem = Tori::Backend::FileSystem.new(path)
    File.open(@filesystem.root.join("testfile"), 'w+'){ |f| f.write('text') }
  end

  teardown do
    FileUtils.rm_rf("test/tmp")
  end

  test "#initialize" do
    assert_instance_of Tori::Backend::FileSystem, @filesystem
    assert_raise(ArgumentError){ Tori::Backend::FileSystem.new }
  end

  test "#exist?" do
    assert { true == @filesystem.exist?(".") }
    assert { false == @filesystem.exist?("nothing_file") }
  end

  test "#read" do
    assert { "text" == @filesystem.read("testfile") }
    assert_raise(Errno::ENOENT){ @filesystem.read("nothing_file") }
  end


  test "#write" do
    assert { 4 == @filesystem.write("copyfile", @filesystem.path("testfile")) }
  end
end
