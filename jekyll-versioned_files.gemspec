
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "jekyll/versioned_files/version"

Gem::Specification.new do |spec|
  spec.name          = "jekyll-versioned_files"
  spec.version       = Jekyll::VersionedFiles::VERSION
  spec.authors       = ["random-parts"]
  spec.email         = ["random-parts@users.noreply.github.com"]

  spec.summary       = %q{Creates a new version-file for a git file.}
  spec.description   = %q{Get a copy of each revision of a file, within a git repository - as a Jekyll Collection of documents.}
  spec.homepage      = "https://github.com/random-parts/jekyll-versioned_files"
  spec.license       = "Apache-2.0"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end

  spec.require_paths = ["lib"]

  spec.add_dependency "jekyll", '~> 3.7'

  spec.add_development_dependency "bundler", "~> 1.16"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "minitest", "~> 5.0"
end
