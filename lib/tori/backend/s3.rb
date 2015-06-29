require 'aws-sdk-core'
require 'mime/types'

module Tori
  module Backend
    class S3
      DEFAULT_CONTENT_TYPE = 'text/plain'.freeze
      attr_accessor :bucket
      # Must be set bucket name.
      #   And it use aws-sdk-core >= 2.0
      #   ENV["TORI_ACCESS_KEY"] > aws-sdk credentials
      #
      # example:
      #   Tori.config.backend = Tori::Backend::S3.new(bucket: 'tori_bucket')
      def initialize(bucket:)
        @bucket = bucket
        @client = nil
      end

      def write(filename, resource, opts = nil)
        opts ||= {}
        case resource
        when String
          put_object({
            key: filename,
            body: resource,
            content_type: DEFAULT_CONTENT_TYPE,
          }.merge(opts))
        when File, Pathname
          path = resource.to_path
          content_type = MIME::Types.type_for(path).first || DEFAULT_CONTENT_TYPE
          ::File.open(path) { |f|
            put_object({
              key: filename,
              body: f,
              content_type: content_type.to_s,
              content_length: f.size,
            }.merge(opts))
          }
        else
          put_object({
            key: filename,
            body: resource,
          }.merge(opts))
        end
      end

      def delete(filename)
        delete_object key: filename
      end

      def exist?(filename = nil)
        head filename
      rescue Aws::S3::Errors::NoSuchKey, Aws::S3::Errors::NotFound
        false
      else
        true
      end
      alias exists? exist?

      def read(filename)
        body(filename).read
      end

      def body(filename)
        get_object(
          key: filename
        )[:body]
      end

      def put(filename, body)
        put_object key: filename, body: body
      end

      def head(filename = nil)
        if filename
          head_object key: filename
        else
          head_bucket
        end
      end

      def public_url(filename)
        "#{client.config.endpoint}/#{@bucket}/#{filename}"
      end

      def url_for(filename, method)
        signer = Aws::S3::Presigner.new(client: client)
        signer.presigned_url(method, bucket: @bucket, key: filename)
      end

      def client
        @client ||= if ENV["TORI_AWS_ACCESS_KEY_ID"] && ENV["TORI_AWS_SECRET_ACCESS_KEY"]
                      Aws::S3::Client.new(
                        access_key_id: ENV["TORI_AWS_ACCESS_KEY_ID"],
                        secret_access_key: ENV["TORI_AWS_SECRET_ACCESS_KEY"],
                        region: ENV["TORI_AWS_REGION"] || ENV['AWS_REGION'] || Aws.config[:region],
                      )
                    else
                      Aws::S3::Client.new(
                        region: ENV["TORI_AWS_REGION"] || ENV['AWS_REGION'] || Aws.config[:region]
                      )
                    end
      end

      def get_object(key:)
        client.get_object bucket: @bucket, key: key
      end

      def head_object(key:)
        client.head_object bucket: @bucket, key: key
      end

      def head_bucket
        client.head_bucket bucket: @bucket
      end

      def put_object(opts = {})
        client.put_object({bucket: @bucket}.merge(opts))
      end

      def delete_object(key:)
        client.delete_object bucket: @bucket, key: key
      end
    end
  end
end
