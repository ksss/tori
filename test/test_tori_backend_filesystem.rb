require 'test_helper'

class TestToriBackendFileSystem < Test::Unit::TestCase
  setup do
    path = Pathname("test/tmp/tori/store")
    @filesystem = Tori::Backend::FileSystem.new(path)
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
    FileUtils.touch @filesystem.root.join("readfile")
    assert { "" == @filesystem.read("readfile") }
    File.unlink @filesystem.root.join("readfile")
    assert_raise(Errno::ENOENT){ @filesystem.read("nothing_file") }
  end
end
