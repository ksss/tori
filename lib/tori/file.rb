module Tori
  class File
    def initialize(model, from: nil)
      @model = model
      @from = from
    end

    def name
      Tori.config.filename_callback.call(@model)
    end
    alias to_s name

    def copy?
      !@model.nil? && !@from.nil? && @from.respond_to?(:path) && 0 < name.length
    rescue NameError => e
      false
    end

    def copy
      Tori.config.backend.copy @from.path, name if copy?
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
