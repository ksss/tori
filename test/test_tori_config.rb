require 'test_helper'

class TestToriConfig < Test::Unit::TestCase
  test "#initialize" do
    i = Tori::Config.new
    assert_instance_of Tori::Config, i
    assert_respond_to i, :backend
    assert_respond_to i, :backend=
    assert_respond_to i, :hash_method
    assert_respond_to i, :hash_method=
  end
end
