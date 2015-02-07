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

  test "#path" do
    assert { Pathname.new("test/tmp/tori/store/testfile") == @filesystem.path("testfile") }
  end

  test "#write" do
    @filesystem.write("copyfile", @filesystem.path("testfile"))
    assert { "text" == @filesystem.read("copyfile") }

    File.open(@filesystem.path("testfile")) do |f|
      @filesystem.write("copyfile", f)
    end
    assert { "text" == @filesystem.read("copyfile") }

    @filesystem.write("copyfile", "string")
    assert { "string" == @filesystem.read("copyfile") }
  end
end
