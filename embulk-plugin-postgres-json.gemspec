
Gem::Specification.new do |gem|
  gem.name          = "embulk-output-postgres-json"
  gem.version       = "0.2.0"

  gem.summary       = %q{Embulk output for PostgreSQL json and jsonb column}
  gem.description   = gem.summary
  gem.authors       = ["Sadayuki Furuhashi"]
  gem.email         = ["frsyuki@gmail.com"]
  gem.license       = "Apache 2.0"
  gem.homepage      = "https://github.com/frsyuki/embulk-output-postgres-json"

  gem.files         = `git ls-files`.split("\n") + Dir["classpath/*.jar"]
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]
  gem.has_rdoc      = false

  gem.add_dependency 'jdbc-postgres', ['>= 3.2.0']
  gem.add_development_dependency 'bundler', ['~> 1.0']
  gem.add_development_dependency 'rake', ['>= 0.9.2']
end
