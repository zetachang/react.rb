# -*- encoding: utf-8 -*-
require File.expand_path('../lib/react/version', __FILE__)

Gem::Specification.new do |s|
  s.name         = 'react.rb'
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
  s.require_paths  = ['lib', 'vendor']

  s.add_runtime_dependency 'opal', '~> 0.7.0'
  s.add_runtime_dependency 'opal-activesupport'
  s.add_runtime_dependency 'sprockets-es6', '~> 0'
  s.add_runtime_dependency 'therubyracer', '~> 0'
  s.add_development_dependency 'react-source', '~> 0.13'
  s.add_development_dependency 'opal-rspec', '~> 0.3.0.beta3'
  s.add_development_dependency 'sinatra', '~> 1'
  s.add_development_dependency 'opal-jquery', '~> 0'
  s.add_development_dependency 'rake', '~> 10'
  s.add_development_dependency 'react-source', '~> 0.12'
  s.add_development_dependency 'opal-rspec'
  s.add_development_dependency 'sinatra'
  s.add_development_dependency 'opal-jquery'
end
