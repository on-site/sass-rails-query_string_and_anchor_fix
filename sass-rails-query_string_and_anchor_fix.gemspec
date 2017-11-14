
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "sass/rails/query_string_and_anchor_fix/version"

Gem::Specification.new do |spec|
  spec.name          = "sass-rails-query_string_and_anchor_fix"
  spec.version       = Sass::Rails::QueryStringAndAnchorFix::VERSION
  spec.authors       = ["Isaac Betesh"]
  spec.email         = ["iybetesh@gmail.com"]

  spec.summary       = <<-SUMMARY.strip
    Support sass-rails 3.x asset helper functions for URLs that contain query string and anchors.
  SUMMARY
  spec.homepage      = "https://github.com/on-site/#{spec.name}"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.16"
  spec.add_development_dependency "rake", "~> 10.0"
end
