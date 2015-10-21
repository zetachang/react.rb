# -*- encoding: utf-8 -*-
$:.push File.expand_path('../lib/', __FILE__)

require 'reactive-ruby/version'

Gem::Specification.new do |s|
  s.name         = 'reactive-ruby'
  s.version      = React::VERSION

  s.author       = 'David Chang'
  s.email        = 'zeta11235813@gmail.com'
  s.homepage     = 'https://github.com/zetachang/react.rb'
  s.summary      = 'Opal Ruby wrapper of React.js library.'
  s.license      = 'MIT'
  s.description  = "Write reactive UI component with Ruby's elegancy and compiled to run in Javascript."

  s.files          = `git ls-files`.split("\n")
  s.executables    = `git ls-files -- bin/*`.split("\n").map { |f| File.basename(f) }
  s.test_files     = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.require_paths  = ['lib']



  s.add_dependency 'opal'
  s.add_dependency 'opal-activesupport', '>= 0.2.0'
  s.add_dependency 'opal-browser'
  s.add_development_dependency 'rake'
  s.add_development_dependency 'rspec-rails'
  s.add_development_dependency 'timecop'
  s.add_development_dependency 'opal-rspec'
  s.add_development_dependency 'sinatra'
  s.add_development_dependency 'sqlite3' # For Test Rails App
end
