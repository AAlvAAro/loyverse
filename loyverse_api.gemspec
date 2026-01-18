require_relative 'lib/loyverse_api/version'

Gem::Specification.new do |spec|
  spec.name          = "loyverse_api"
  spec.version       = LoyverseApi::VERSION
  spec.authors       = ["Loyverse API Wrapper"]
  spec.email         = ["api@example.com"]

  spec.summary       = %q{Ruby wrapper for the Loyverse API}
  spec.description   = %q{A comprehensive Ruby gem for interacting with the Loyverse API, supporting authentication, webhooks, and all major resources including items, inventory, receipts, and categories.}
  spec.homepage      = "https://github.com/yourusername/loyverse_api"
  spec.license       = "MIT"
  spec.required_ruby_version = Gem::Requirement.new(">= 2.6.0")

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = "#{spec.homepage}/blob/main/CHANGELOG.md"

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "faraday", "~> 2.0"
  spec.add_dependency "faraday-retry", "~> 2.0"

  spec.add_development_dependency "bundler", "~> 2.0"
  spec.add_development_dependency "rake", "~> 13.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "webmock", "~> 3.0"
  spec.add_development_dependency "vcr", "~> 6.0"
end
