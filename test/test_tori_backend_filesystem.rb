require 'test_helper'

class TestToriBackendFileSystem < Test::Unit::TestCase
  class Uploader
    def path
      "/tmp/tori/test"
    end
  end

  test "#initialize" do
    path = Pathname("tmp/tori/test")
    i = Tori::Backend::FileSystem.new(path)

    assert_instance_of Tori::Backend::FileSystem, i
    assert_raise(ArgumentError){ Tori::Backend::FileSystem.new }
  end
end
