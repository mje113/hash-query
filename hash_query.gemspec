# -*- encoding: utf-8 -*-
require File.expand_path('../lib/hash_query/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ['Mike Evans']
  gem.email         = ['mike@urlgonomics.com']
  gem.description   = %q{Provides a css-like selector system for querying values out of deeply nested hashes}
  gem.summary       = %q{See above}
  gem.homepage      = 'https://github.com/mje113/hash-query'

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = 'hash-query'
  gem.require_paths = ['lib']
  gem.version       = HashQuery::VERSION

  gem.add_development_dependency 'rake'
  gem.add_development_dependency 'coveralls'
end
