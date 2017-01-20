# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'rails_admin_settings/version'

Gem::Specification.new do |spec|
  spec.name          = "ack_rails_admin_settings"
  spec.version       = RailsAdminSettings::VERSION
  spec.authors       = ["Alexander Kiseliev", "Gleb Tv"]
  spec.email         = ['i43ack@gmail.com', "glebtv@gmail.com"]
  spec.description   = %q{Mongoid / ActiveRecord + RailsAdmin App Settings management}
  spec.summary       = %q{}
  spec.homepage      = "https://github.com/red-rocks/rails_admin_settings"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]


  spec.add_development_dependency "mongoid", [">= 3.0", "< 7.0"]
  spec.add_development_dependency "rails"
  spec.add_development_dependency "bundler"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "mongoid-rspec"
  spec.add_development_dependency "simplecov"
  spec.add_development_dependency "database_cleaner"
  spec.add_development_dependency "factory_girl"
  spec.add_development_dependency "safe_yaml"
  spec.add_development_dependency "russian_phone"
  spec.add_development_dependency "sanitize"
  spec.add_development_dependency "validates_email_format_of"
  spec.add_development_dependency "geocoder"
  spec.add_development_dependency "addressable"
  spec.add_development_dependency "glebtv-carrierwave-mongoid"
  spec.add_development_dependency "glebtv-mongoid-paperclip"
  spec.add_development_dependency "pry"
end
