module Tori
  class File
    def initialize(model, from: nil, &block)
      @model = model
      if from.respond_to?(:read) and from.respond_to?(:rewind)
        from.rewind
        @from = from.read
      else
        @from = from
      end
      @filename_callback = block
    end

    def name
      if @filename_callback
        @filename_callback.call(@model)
      else
        Tori.config.filename_callback.call(@model)
      end
    end
    alias to_s name

    def from?
      !@from.nil?
    end

    def write(opts = nil)
      Tori.config.backend.write name, @from, opts
    end

    def delete
      Tori.config.backend.delete name if exist?
    end

    private

    def respond_to_missing?(sym, include_private)
      Tori.config.backend.respond_to?(sym, include_private)
    end

    def method_missing(sym, *args)
      if respond_to_missing?(sym, false)
        Tori.config.backend.__send__ sym, name, *args
      else
        fail NameError, "undefined method `#{sym}' for #{Tori.config.backend.inspect}"
      end
    end
  end
end
