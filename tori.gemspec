lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "tori/version"

Gem::Specification.new do |spec|
  spec.name          = "tori"
  spec.version       = Tori::VERSION
  spec.authors       = ["ksss"]
  spec.email         = ["co000ri@gmail.com"]
  spec.summary       = %q{Simple file uploader}
  spec.description   = %q{Simple file uploader}
  spec.homepage      = "https://github.com/ksss/tori"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "aws-sdk-s3"
  spec.add_runtime_dependency "mime-types"
  spec.add_runtime_dependency 'rexml'
  spec.add_development_dependency "bundler"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "test-unit"
end
