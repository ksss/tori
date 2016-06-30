Aws.config[:s3] = {
  stub_responses: {
    head_bucket: {},
    get_object: {
      content_type: "text/plain",
      body: "foo",
      content_length: 3,
    }
  }
}
