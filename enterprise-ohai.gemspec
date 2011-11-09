dir = File.dirname(__FILE__)

Gem::Specification.new do |s|
  s.name    = 'enterprise-ohai'
  s.version = '0.1.0'
  s.summary = s.description = 'Ohai plugins for enterprise.'
  s.authors = %w[GitHub]

  s.files         = Dir[File.join(dir, 'lib', '**', '*')]
  s.require_paths = %w[lib]

  s.bindir      = 'bin'
  s.executables = %w[enterprise-ohai]

  s.add_dependency 'ohai'
  s.add_dependency 'json'
end
