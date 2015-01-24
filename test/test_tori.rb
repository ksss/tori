require 'test_helper'

class TestTori < Test::Unit::TestCase
  test "config instance of" do
    assert_instance_of Tori::Config, Tori.config
  end

  test "config default" do
    assert_instance_of Tori::Backend::FileSystem, Tori.config.backend
    assert { Digest::MD5.method(:hexdigest) == Tori.config.hash_method }
  end
end
