# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = 'rypper'
  s.version = '0.0.2'
  s.summary = 'Rypper'
  s.description = 'Rypper'
  s.author = 'Michael Nowak'
  s.email = 'thexsystem@gmail.com'
  s.homepage = 'https://github.com/THExSYSTEM/rypper'
  s.files = Dir['lib/**/*.rb']
  s.executables = Dir['bin/*'].map {|bin| File.basename(bin) }
  s.default_executable = 'rypper'
  s.require_path = 'lib'
  s.required_ruby_version = '>= 1.8.7'
  s.add_dependency 'nokogiri', '~> 1.5'
  s.has_rdoc = false
  s.rdoc_options = ['--charset=UTF-8']
end