require 'test_helper'

class TestToriConfig < Test::Unit::TestCase
  test "#initialize" do
    i = Tori::Config.new
    assert_instance_of Tori::Config, i
  end
end
