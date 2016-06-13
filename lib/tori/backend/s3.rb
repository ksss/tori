require 'aws-sdk-core'
require 'mime/types'

module Tori
  module Backend
    class S3
      DEFAULT_CONTENT_TYPE = 'text/plain'.freeze
      attr_accessor :bucket
      attr_reader   :client

      class << self
        def type_for(path)
          (MIME::Types.type_for(path).first || DEFAULT_CONTENT_TYPE).to_s
        end
      end

      # Must be set bucket name.
      #   And it use aws-sdk-core >= 2.0
      #   ENV takes precedence over credentials file and instance profile
      #
      # example:
      #   Tori.config.backend = Tori::Backend::S3.new(bucket: 'tori_bucket')
      #   # or
      #   Tori.config.backend = Tori::Backend::S3.new(
      #     bucket: 'tori_bucket',
      #     client: Aws::S3::Client.new(
      #       access_key_id: 'your_access_key',
      #       secret_access_key: 'your_secret_access_key',
      #       region: 'your-region-1'
      #     )
      #   )
      def initialize(bucket:, client: nil)
        @bucket = bucket
        if client
          unless client.kind_of?(Aws::S3::Client)
            raise TypeError, "client should be instance of Aws::S3::Client or nil"
          end
          @client = client
        else
          region = ENV['TORI_AWS_REGION'] || ENV['AWS_REGION'] || Aws.config[:region]
          @client = if ENV['TORI_AWS_ACCESS_KEY_ID'] && ENV['TORI_AWS_SECRET_ACCESS_KEY']
                      Aws::S3::Client.new(
                        access_key_id:     ENV['TORI_AWS_ACCESS_KEY_ID'],
                        secret_access_key: ENV['TORI_AWS_SECRET_ACCESS_KEY'],
                        region:            region,
                      )
                    else
                      # Use instance profile or credentials file (~/.aws/credentials)
                      Aws::S3::Client.new(region: region)
                    end
        end
      end

      def write(filename, resource, opts = nil)
        opts ||= {}
        if from_path = opts.delete(:from_path)
          opts[:content_type] = self.class.type_for(from_path)
        end

        if resource.nil? && opts[:body]
          resource = opts[:body]
        end

        case resource
        when String
          put_object({
            key: filename,
            body: resource,
            content_type: DEFAULT_CONTENT_TYPE,
          }.merge(opts))
        when File, Pathname
          path = resource.to_path
          content_type = self.class.type_for(path)
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
            content_type: DEFAULT_CONTENT_TYPE,
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

      def read(filename, **opts)
        body(filename, **opts).read
      end

      def body(filename, **opts)
        get(filename, **opts)[:body]
      end

      def get(filename, **opts)
        get_object(key: filename, **opts)
      end

      def put(filename, body, **opts)
        put_object key: filename, body: body, **opts
      end

      def head(filename = nil, **opts)
        if filename
          head_object key: filename, **opts
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

      def open(filename, opts = {})
        names = [::File.basename(filename), ::File.extname(filename)]
        tmpdir = opts.delete(:tmpdir)

        if block_given?
          Tempfile.create(names, tmpdir, opts) do |f|
            get_object(key: filename, response_target: f.path)
            yield f
          end
        else
          f = Tempfile.open(names, tmpdir, opts)
          get_object(key: filename, response_target: f.path)
          f
        end
      end

      def otherwise(backend)
        Chain.new(self, backend)
      end

      def get_object(opts={})
        client.get_object bucket: @bucket, **opts
      end

      def head_object(opts={})
        client.head_object bucket: @bucket, **opts
      end

      def head_bucket(opts={})
        client.head_bucket bucket: @bucket, **opts
      end

      def put_object(opts = {})
        client.put_object bucket: @bucket, **opts
      end

      def delete_object(opts={})
        client.delete_object bucket: @bucket, **opts
      end

      def copy_object(opts = {})
        client.copy_object bucket: @bucket, **opts
      end
    end
  end
end
