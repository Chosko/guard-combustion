require File.expand_path("../lib/guard/combustion/version", __FILE__)

Gem::Specification.new do |s|
  s.name         = "guard-combustion"
  s.author       = "Ruben Caliandro"
  s.email        = "ruben.caliandro@gmail.com"
  s.summary      = "Guard gem for running Combustion"
  s.homepage     = "http://github.com/Chosko/guard-combustion"
  s.license      = 'MIT'
  s.version      = Guard::CombustionVersion::VERSION

  s.description  = <<-DESC
    Guard::Combustion automatically restarts Combustion when watched files are
    modified.
  DESC

  s.add_dependency 'guard', '>= 1.1.0'

  s.files        = %w(README.md LICENSE)
  s.files       += Dir["{lib}/**/*"]
end
