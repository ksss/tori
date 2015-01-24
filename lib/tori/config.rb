module Tori
  class Config
    attr_accessor :backend, :filename_callback
    def initialize
      @backend = nil
      @filename_callback = nil
    end
  end
end
