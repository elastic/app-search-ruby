$:.push File.expand_path("../lib", __FILE__)
require "elastic/app-search/version"

Gem::Specification.new do |s|
  s.name        = "elastic-app-search"
  s.version     = Elastic::AppSearch::VERSION
  s.authors     = ["Quin Hoxie"]
  s.email       = ["support@elastic.co"]
  s.homepage    = "https://github.com/elastic/app-search-ruby"
  s.summary     = %q{Official gem for accessing the Elastic App Search API}
  s.description = %q{API client for accessing the Elastic App Search API with no dependencies.}
  s.licenses    = ['Apache-2.0']

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_development_dependency 'awesome_print', '~> 1.8'
  s.add_development_dependency 'pry', '~> 0.11.3'
  s.add_development_dependency 'rspec', '~> 3.0'
  s.add_development_dependency 'webmock', '~> 3.3'

  s.add_runtime_dependency 'jwt', '>= 1.5', '< 3.0'
end
