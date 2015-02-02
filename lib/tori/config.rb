module Tori
  class Config
    attr_accessor :backend
    def initialize
      @backend = nil
      @filename_callback = nil
    end

    def filename_callback(&block)
      if block_given?
        @filename_callback = block
      else
        @filename_callback
      end
    end
  end
end
