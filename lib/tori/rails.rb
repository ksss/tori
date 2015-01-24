require 'tori'

module Tori
  class Engine < Rails::Engine
    initializer "tori.setup", before: :load_environment_config do
      # Default backend config
      # You can change setting any time.
      # Recommend to create config/initializer/tori.rb for setting.

      # Configure for file store backend instance.
      Tori.config.backend = Tori::Backend::FileSystem.new(Rails.root.join('tmp', 'tori'))

      # Filename hashing method
      #   It's call when decide filename hash.
      #   `hash_method` must be have `call` method.
      #   default: `Digest::MD5.method(:hexdigest)``
      # Tori.config.hash_method = Digest::MD5.method(:hexdigest)
    end
  end

  module ActiveRecord
    include Define

    # Filename hash usgin `id` attribute by default.
    # And you can change this attribute, But it's should be record unique.
    #
    # @example:
    # class Photo < ActiveRecord::Base
    #   tori :image, id: :id
    # end
    def tori(name, id: :id)
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
