require 'test_helper'
require 'tori/backend/s3'

if ENV["TORI_TEST_BUCKET"]

class TestToriBackendS3 < Test::Unit::TestCase
  BucketNotFoundError = Class.new(StandardError)
  def request_head(url)
    uri = URI.parse(url)
    req = Net::HTTP::Head.new(uri.path)
    Net::HTTP.start(uri.host, uri.port, use_ssl: uri.scheme == 'https') { |http|
      http.request req
    }
  end

  setup do
    @backend = Tori::Backend::S3.new(bucket: ENV["TORI_TEST_BUCKET"])
    fail BucketNotFoundError, "S3 test need make s3 bucket '#{@backend.bucket}'" unless @backend.exists?

    @testfile_path = Pathname.new("test/tmp/testfile")
    FileUtils.mkdir_p "test/tmp"
    File.open(@testfile_path.to_s, 'w+'){ |f| f.write('text') }
    @backend.write("testfile", @testfile_path)
  end

  teardown do
    FileUtils.rm_rf("test/tmp")
  end

  test "auto content_type" do
    Tempfile.create(["test", ".jpeg"]) do |f|
      file = Tori::File.new(:dummy, from: f, to: @backend){ |model| "test-key" }
      begin
        file.write
        content_type = file.get.content_type
        assert { 'image/jpeg' == content_type }
      ensure
        file.delete
      end
    end
  end

  test "#initialize" do
    assert_instance_of Tori::Backend::S3, @backend
    assert { ENV["TORI_AWS_ACCESS_KEY_ID"] == @backend.client.config.access_key_id }
    assert { ENV["TORI_AWS_SECRET_ACCESS_KEY"] == @backend.client.config.secret_access_key }

    custom_backend = Tori::Backend::S3.new(
      bucket: ENV["TORI_TEST_BUCKET"],
      client: Aws::S3::Client.new(access_key_id: 'aaa', secret_access_key: 'bbb'),
    )
    assert_instance_of Tori::Backend::S3, custom_backend
    assert { 'aaa' == custom_backend.client.config.access_key_id }
    assert { 'bbb' == custom_backend.client.config.secret_access_key }

    assert_raise(ArgumentError){ Tori::Backend::S3.new }
    assert_raise(TypeError) {
      Tori::Backend::S3.new(
        bucket: ENV["TORI_TEST_BUCKET"],
        client: Object.new,
      )
    }
  end

  test "#respond_to_missing?" do
    %i(exists? read delete).each do |m|
      assert { true == @backend.respond_to?(m) }
    end
  end

  test "#write String" do
    @backend.write("testfile", "foo", content_type: "image/png")
    testfile = @backend.get_object(key: "testfile")
    assert { "image/png" == testfile.content_type }
    assert { "foo" == testfile[:body].read }
  end

  test "#write Pathname" do
    assert_nothing_raised { @backend.write("testfile", @testfile_path) }
    testfile = @backend.get_object(key: "testfile")
    assert { "text/plain" == testfile.content_type }
    assert { 4 == testfile.content_length }
    assert { "text" == testfile[:body].read }

    @backend.write("testfile", @testfile_path, acl: "public-read-write")
    res = request_head(@backend.public_url("testfile"))
    assert { Net::HTTPOK === res}

    @backend.write("testfile", @testfile_path, acl: "private")
    res = request_head(@backend.public_url("testfile"))
    assert { Net::HTTPForbidden === res}
  end

  test "#read" do
    assert_equal "text", @backend.read("testfile")
  end

  test "#exists?" do
    assert_nothing_raised { @backend.exists?("nothingfile") }
    assert { true == @backend.exists?("testfile") }
  end

  test "#delete" do
    assert_nothing_raised { @backend.delete("testfile") }
    assert { false == @backend.exists?("testfile") }
  end

  test "#public_url" do
    assert_match %r!https?://s3-!, @backend.public_url("testfile")
    assert_match @backend.bucket, @backend.public_url("testfile")
    assert_match "testfile", @backend.public_url("testfile")
  end

  test "#open" do
    path = nil
    @backend.open("testfile") do |f|
      assert_instance_of File, f
      assert { "text" == f.read }
      path = f.path
    end
    assert { false == File.exist?(path) }
    f = @backend.open("testfile", tmpdir: "/tmp")
    assert_instance_of Tempfile, f
    assert { f.path =~ %r{/tmp/.*} }
    f.close!

    @backend.write("path/to/file", @testfile_path)
    @backend.open("path/to/file") do |f|
      assert_instance_of File, f
      assert { "text" == f.read }
    end
  end
end

end
