module Tori
  class File
    def initialize(model, title: nil, from: nil, &block)
      @model = model
      @title = title.kind_of?(String) ? title.to_sym : title
      if from.respond_to?(:read) and from.respond_to?(:rewind)
        from.rewind
        @from = from.read
      else
        @from = from
      end
      @filename_callback = block
    end

    def name
      context = Context.new(@title)
      if @filename_callback
        context.define_singleton_method(:__bind__, @filename_callback)
        context.__bind__(@model)
      else
        context.define_singleton_method(:__bind__, Tori.config.filename_callback)
        context.__bind__(@model)
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
