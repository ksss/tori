module Tori
  class File
    def initialize(model, from = nil)
      @model = model
      @from = from
    end

    def name
      Tori.config.filename_callback.call(@model)
    end
    alias to_s name

    def exist?
      Tori.config.backend.exist? name
    end

    def copy?
      !@model.nil? && !@from.nil? && @from.respond_to?(:path) && 0 < name.length
    rescue NameError => e
      false
    end

    def read
      Tori.config.backend.read name
    end

    def copy
      Tori.config.backend.copy @from.path, name if copy?
    end

    def delete
      Tori.config.backend.delete name if exist?
    end
  end
end
