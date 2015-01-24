require 'tori'

module Tori
  module ActiveRecord
    include Define

    # Filename hash usgin `id` attribute by default.
    # And you can change this attribute, But it's should be record unique.
    #
    # @example:
    # class Photo < ActiveRecord::Base
    #   tori :image, id: :id
    # end
    def tori(name)
      super

      name_hash_get = "#{name}_hash".to_sym

      after_save do
        uploader = __send__ name
        filename = __send__ name_hash_get
        Tori.config.backend.copy(uploader.path, filename) if uploader && filename
      end

      after_destroy do
        filename = __send__ name_hash_get
        Tori.config.backend.delete(filename) if filename
      end
    end
  end
end
::ActiveRecord::Base.extend(Tori::ActiveRecord)
