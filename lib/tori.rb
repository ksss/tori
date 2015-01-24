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
        config.backend = Tori::Backend::FileSystem.new(Pathname("tmp/tori"))
        config.hash_method = Digest::MD5.method(:hexdigest)
      end
    end
  end
end
