require 'aws-sdk'

module Tori
  module Backend
    class S3
      # Must be set bucket name.
      #   And it use aws-sdk >= 2.0
      #   ENV["TORI_ACCESS_KEY"] > aws-sdk credentials
      #
      # example:
      #   Tori.config.backend = Tori::Backend::S3.new(bucket: 'tori_bucket')
      def initialize(bucket:)
        @bucket = bucket
        @client = if ENV["TORI_ACCESS_KEY"] && ENV["TORI_SECRET_ACCESS_KEY"]
                    Aws::S3::Client.new(
                      access_key_id: ENV["TORI_ACCESS_KEY"],
                      secret_access_key: ENV["TORI_SECRET_ACCESS_KEY"],
                      region: ENV["TORI_AWS_REGION"] || ENV['AWS_REGION'] || Aws.config[:region],
                    )
                  else
                    Aws::S3::Client.new(
                      region: ENV["TORI_AWS_REGION"] || ENV['AWS_REGION'] || Aws.config[:region]
                    )
                  end
      end

      def write(filename, resource)
        ::File.open(resource) do |f|
          @client.put_object(
            bucket: @bucket,
            key: filename,
            body: f
          )
        end
      end

      def delete(filename)
        @client.delete_object(
          bucket: @bucket,
          key: filename
        )
      end

      def exist?(filename)
        @client.head_object(
          bucket: @bucket,
          key: filename
        )
      rescue Aws::S3::Errors::NoSuchKey, Aws::S3::Errors::NotFound
        false
      else
        true
      end
      alias exists? exist?

      def read(filename)
        @client.get_object(
          bucket: @bucket,
          key: filename
        )[:body].read
      end

      def public_url(filename, params={})
        scheme = params.delete(:secure) == false ? 'http' : 'https'

        request = @client.build_request(:get_object)
        request.send_request.data

        url = URI.parse(request.send_request.data)
        url.scheme = scheme
        url.to_s
      end

      def url_for(filename, method)
        signer = Aws::S3::Presigner.new(client: @client)
        signer.presigned_url(method, bucket: @bucket, key: filename)
      end
    end
  end
end
