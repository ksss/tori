require 'test_helper'

class TestToriBackendChain < Test::Unit::TestCase
  include Tori::Backend

  setup do
    @filesystem1 = FileSystem.new(Pathname("test/tmp/tori/store1"))
    File.open(@filesystem1.root.join("testfile-1"), 'w+'){ |f| f.write("text-1") }

    @filesystem2 = FileSystem.new(Pathname("test/tmp/tori/store2"))
    File.open(@filesystem2.root.join("testfile-2"), 'w+'){ |f| f.write("text-2") }

    @backend = Chain.new(@filesystem1, @filesystem2)
  end

  test "#initialize" do
    assert { Chain === Chain.new }
    assert { [@filesystem1, @filesystem2] === Chain.new(@filesystem1, @filesystem2).backends }
    assert { Chain === @filesystem1.otherwise(@filesystem2) }
  end

  test "#backend" do
    assert { @filesystem1 == @backend.backend("testfile-1") }
    assert { @filesystem2 == @backend.backend("testfile-2") }
    assert_raise(Chain::ExistError) { @backend.backend("testfile-3") }
  end

  test "#exist?" do
    assert { true == @backend.exist?("testfile-1") }
    assert { true == @backend.exist?("testfile-2") }
    assert { false == @backend.exist?("testfile-3") }
  end

  test "read" do
    assert { "text-1" == @backend.read("testfile-1") }
    assert { "text-2" == @backend.read("testfile-2") }
    assert_raise(Chain::ExistError) { @backend.read("testfile-3") }
  end

  test "open" do
    @backend.open("testfile-1") do |f|
      assert { "text-1" == f.read }
      assert { "test/tmp/tori/store1/testfile-1" == f.path }
    end
    @backend.open("testfile-2") do |f|
      assert { "text-2" == f.read }
      assert { "test/tmp/tori/store2/testfile-2" == f.path }
    end
    assert_raise(Chain::ExistError) { @backend.read("testfile-3") }
  end
end
