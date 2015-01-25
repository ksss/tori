module Tori
  class File
    attr_accessor :from

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
  end
end
