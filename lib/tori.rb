require 'tori/backend/filesystem'
require 'tori/config'
require 'tori/define'
require 'tori/file'
require 'tori/version'
require 'pathname'
require 'digest/sha1'
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

        # You can also use S3 backend.
        # It take 'aws-sdk-core' gem.
        # S3 example
        #   require 'tori/backend/s3'
        #   config.backend = Tori::Backend::S3.new(bucket: 'tori_bucket')

        # Filename hashing method
        #   It's call when decide filename hash.
        config.filename_callback do |model, key|
          Digest::SHA1.hexdigest "#{model.class.name}/#{model.id}"
        end
      end
    end
  end
end
