module Tori
  class Context
    def initialize(name)
      @name = name
    end

    def __tori__
      @name
    end
  end
end
