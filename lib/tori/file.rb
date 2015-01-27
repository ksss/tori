module Tori
  class File
    def initialize(model, from = nil)
      @model = model
      @from = from
    end

    def to_s
      Tori.config.filename_callback.call(@model)
    end

    def exist?
      Tori.config.backend.exist?(to_s)
    end

    def copy?
      !@model.nil? && !@from.nil? && @from.respond_to?(:path) && 0 < to_s.length
    rescue NameError => e
      false
    end

    def read
      Tori.config.backend.read(to_s)
    end

    def copy
      Tori.config.backend.copy(@from.path, to_s) if copy?
    end

    def delete
      Tori.config.backend.delete(to_s) if exist?
    end
  end
end
