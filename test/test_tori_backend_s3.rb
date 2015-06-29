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
    @backend.delete("testfile")
  end

  test "#initialize" do
    assert_instance_of Tori::Backend::S3, @backend
    assert_raise(ArgumentError){ Tori::Backend::S3.new }
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
end

end
