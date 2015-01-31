require 'aws-sdk'

module Tori
  module Backend
    class S3
      # You must be set bucket name.
      #   And you can configurate to S3
      #   But, you can also configurate by AWS.config()
      #
      # example:
      #   Tori.config.backend = Tori::Backend::S3.new(
      #     bucket: 'photos',
      #     region: '...',
      #     s3_encryption_key: '...'
      #   )
      def initialize(bucket:, **s3_config)
        s3 = AWS::S3.new(s3_config)
        @bucket = s3.buckets[bucket]
      end

      def copy(form_path, to_filename)
        objects[filename].write(file: form_path)
      end

      def delete(filename)
        objects[filename].delete
      end

      def exist?(filename)
        objects[filename].exists?
      end

      def read(filename)
        objects[filename].read
      end

      private
      def objects
        @bucket.objects
      end
    end
  end
end
