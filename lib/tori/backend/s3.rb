require 'aws-sdk-core'

module Tori
  module Backend
    class S3
      attr_accessor :bucket, :client
      # Must be set bucket name.
      #   And it use aws-sdk-core >= 2.0
      #   ENV["TORI_ACCESS_KEY"] > aws-sdk credentials
      #
      # example:
      #   Tori.config.backend = Tori::Backend::S3.new(bucket: 'tori_bucket')
      def initialize(bucket:)
        @bucket = bucket
        @client = if ENV["TORI_AWS_ACCESS_KEY_ID"] && ENV["TORI_AWS_SECRET_ACCESS_KEY"]
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

      def write(filename, resource)
        case resource
        when IO
          put filename, f
        when String
          put filename, resource
        else
          ::File.open(resource.to_path) { |f| put filename, f }
        end
      end

      def put(filename, body)
        @client.put_object(
          bucket: @bucket,
          key: filename,
          body: body
        )
      end

      def delete(filename)
        @client.delete_object(
          bucket: @bucket,
          key: filename
        )
      end

      def exist?(filename = nil)
        head filename
      rescue Aws::S3::Errors::NoSuchKey, Aws::S3::Errors::NotFound
        false
      else
        true
      end
      alias exists? exist?

      def head(filename = nil)
        if filename
          @client.head_object bucket: @bucket, key: filename
        else
          @client.head_bucket bucket: @bucket
        end
      end

      def read(filename)
        @client.get_object(
          bucket: @bucket,
          key: filename
        )[:body].read
      end

      def public_url(filename, params={})
        "#{@client.config.endpoint}/#{@bucket}/#{filename}"
      end

      def url_for(filename, method)
        signer = Aws::S3::Presigner.new(client: @client)
        signer.presigned_url(method, bucket: @bucket, key: filename)
      end
    end
  end
end
