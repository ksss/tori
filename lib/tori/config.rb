module Tori
  class Config
    attr_accessor :backend, :hash_method
    def initialize
      @backend = nil
      @hash_method = nil
    end
  end
end
