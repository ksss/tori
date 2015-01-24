require 'tori/backend/filesystem'
require 'tori/config'
require 'tori/define'
require 'tori/version'
require 'pathname'
require 'digest/md5'
require "fileutils"

module Tori
  class << self
    def config
      @config ||= Config.new.tap do |config|
        # Default backend config
        #   You can change setting any time.
        #   Recommend to create config/initializer/tori.rb for setting.

        # Configure for file store backend instance.
        config.backend = Tori::Backend::FileSystem.new(Pathname("tmp/tori"))

        # Filename hashing method
        #   It's call when decide filename hash.
        #   `filename_callback` must be have `call` method.
        config.filename_callback = ->(model) do
          Digest::MD5.hexdigest "#{model.class.name}/#{model.id}"
        end
      end
    end
  end
end
