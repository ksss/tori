module Tori
  class File
    def initialize(model, title: nil, from: nil, to: nil, &block)
      @model = model
      @title = title.kind_of?(String) ? title.to_sym : title
      @backend = to
      @filename_callback = block

      self.from = from
    end

    def name
      context = Context.new(@title)
      context.define_singleton_method(:__filename_callback__, filename_callback)
      context.__filename_callback__(@model)
    end
    alias to_s name

    def from
      @from
    end

    def from=(file)
      @from_path = if file.respond_to?(:path)
        file.path
      else
        nil
      end
      @from = if file.respond_to?(:read) and file.respond_to?(:rewind)
        file.rewind
        file.read
      else
        file
      end
    end

    def from?
      !@from.nil?
    end

    def write(opts = nil)
      opts ||= {}
      backend.write name, @from, opts.merge(from_path: @from_path)
    end

    def delete
      backend.delete name if exist?
    end

    def filename_callback
      @filename_callback || Tori.config.filename_callback
    end

    def backend
      @backend || Tori.config.backend
    end

    def backend=(new_backend)
      @backend = new_backend
    end

    private

    def respond_to_missing?(sym, include_private)
      backend.respond_to?(sym, include_private)
    end

    def method_missing(sym, *args, &block)
      if respond_to_missing?(sym, false)
        backend.__send__ sym, name, *args, &block
      else
        fail NameError, "undefined method `#{sym}' for #{Tori.config.backend.inspect}"
      end
    end
  end
end
