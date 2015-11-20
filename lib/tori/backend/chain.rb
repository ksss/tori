module Tori
  module Backend
    # Chain based on `exist?` method
    # @example
    #   class Book < ActiveRecord::Base
    #     include Tori::Backend # short cut
    #
    #     # If exist "lib/pdf" load this,
    #     # But nothing, Load from S3 "book" bucket.
    #     chain_backend = Chain.new(
    #       FileSystem.new(Pathname("lib/pdf")),
    #       S3.new(bucket: "book"),
    #     )
    #     tori :pdf, chain_backend do |model|
    #       "book/#{__tori__}/#{model.id}"
    #     end
    #   end
    class Chain
      class ExistError < StandardError
      end

      attr_accessor :backends

      def initialize(*backends)
        @backends = backends
      end

      def backend(filename)
        @backends.each do |b|
          if b.exist?(filename)
            return b
          end
        end
        raise ExistError, "exist(#{filename}) backend not found"
      end

      def exist?(filename)
        backend(filename)
      rescue ExistError
        false
      else
        true
      end

      def read(filename)
        backend(filename).read(filename)
      end

      def open(filename, &block)
        backend(filename).open(filename, &block)
      end
    end
  end
end
