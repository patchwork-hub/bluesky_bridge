require_relative "lib/bluesky_bridge/version"

Gem::Specification.new do |spec|
  spec.name        = "bluesky_bridge"
  spec.version     = BlueskyBridge::VERSION
  spec.authors     = [ "Aung Kyaw Phyo" ]
  spec.email       = [ "kiru.kiru28@gmail.com" ]
  spec.homepage    = "https://github.com/patchwork-hub/bluesky_bridge"
  spec.summary     = "A gem to create Bluesky Bridge account for mastodon."
  spec.description = "A gem to create Bluesky Bridge account for mastodon."
  spec.license     = "MIT"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the "allowed_push_host"
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  spec.metadata["allowed_push_host"] = "https://rubygems.org"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = "#{spec.homepage}/CHANGELOG.md"

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]
  end

  spec.add_dependency "rails", ">= 8.0"
end
