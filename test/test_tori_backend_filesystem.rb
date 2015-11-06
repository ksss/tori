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
    assert { true == @filesystem.exist?("testfile") }
    assert { false == @filesystem.exist?("nothing_file") }
  end

  test "#read" do
    assert { "text" == @filesystem.read("testfile") }
    assert_raise(Errno::ENOENT){ @filesystem.read("nothing_file") }
    bin = (0..0xFF).to_a.pack("c*")
    File.open(@filesystem.root.join("binfile"), 'wb'){ |f| f.write bin }
    assert { bin == @filesystem.read("binfile") }
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

    bin = (0..0xFF).to_a.pack("c*")
    @filesystem.write("binfile", bin)
    assert { bin == @filesystem.read("binfile") }

    @filesystem.write(Pathname.new("copyfile"), @filesystem.path("testfile"))
    assert { "text" == @filesystem.read("copyfile") }

    @filesystem.write(Pathname.new("copyfile"), "string")
    assert { "string" == @filesystem.read("copyfile") }
  end

  test "#open" do
    @filesystem.open("testfile") do |f|
      assert_instance_of File, f
    end
    f = @filesystem.open("testfile")
    assert_instance_of File, f
    f.close
  end
end
