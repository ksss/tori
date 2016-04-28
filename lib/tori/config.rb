module Tori
  class Config
    attr_accessor :backend
    def initialize
      @backend = nil
      @filename_callback = nil
    end

    def filename_callback(&block)
      warn "DEPRECATED: `#{__method__}' is deprecated method."
      warn "Please use `tori` method block style in model like `tori :name, { |model| model.id }`."
      if block_given?
        @filename_callback = block
      else
        @filename_callback
      end
    end
  end
end
