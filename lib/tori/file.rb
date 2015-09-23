module Tori
  class File
    def initialize(model, key, from: nil, &block)
      @model = model
      @key   = key

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
        if @filename_callback.lambda? && @filename_callback.arity == 1
          warn '[DEPRECATION] filename_callback should be received two arguments.'
          @filename_callback.call(@model)
        else
          @filename_callback.call(@model, @key)
        end
      else
        Tori.config.filename_callback.call(@model, @key)
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
