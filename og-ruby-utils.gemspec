version = File.read(File.expand_path('../VERSION', __FILE__)).strip

Gem::Specification.new do |s|
  s.name              = 'og-ruby-utils'
  s.version           = version
  s.date              = '2016-02-01'
  s.summary           = "OpenGov ruby Utils"
  s.description       = "Commonly used utils and connectors for OpenGov rails stack projects"
  s.authors           = ["OpenGov"]
  s.email             = 'dev@opengov.com'
  s.require_paths     = ['lib']
  s.files             += Dir['lib/**/*.rb']
  s.homepage          = 'https://github.com/OpenGov/og-ruby-utils'
  s.license           = 'Nonstandard'

  s.require_paths     = ["lib"]
  s.add_dependency('fog-aws', '~> 0.9.1')
end
