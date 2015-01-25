require 'tori'

module Tori
  module ActiveRecord
    include Define

    # Filename hash usgin `id` attribute by default.
    # And you can change this attribute, But it's should be record unique.
    #
    # @example:
    # class Photo < ActiveRecord::Base
    #   tori :image
    # end
    def tori(name)
      super

      after_save do
        file = __send__ name
        Tori.config.backend.copy(file.from.path, file.to_s) if file.from && file.copy?
      end

      after_destroy do
        file = __send__ name
        Tori.config.backend.delete(file.to_s) if file.exist?
      end
    end
  end
end
::ActiveRecord::Base.extend(Tori::ActiveRecord)
