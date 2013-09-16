files = ['README.md', 'LICENSE', 'Rakefile', 'abcrab.gemspec', '{spec,lib}/**/*'].map {|f| Dir[f]}.flatten

spec = Gem::Specification.new do |s|
  s.name = "abcrab"
  s.version = "0.0.1"
  s.rubyforge_project = "abcrab"
  s.description = "Mixpanel based A/B testing"
  s.author = "Tom Brown"
  s.email = "tom@joingrouper.com"
  s.homepage = "http://github.com/grouper/abcrab"
  s.platform = Gem::Platform::RUBY
  s.summary = "Supports direct request api and javascript requests through a middleware."
  s.files = files
  s.require_path = "lib"
  s.has_rdoc = false
  s.extra_rdoc_files = ["README.md"]
  s.add_dependency 'mixpanel'
  s.add_development_dependency 'rspec'
  s.add_development_dependency 'rack-test'
  s.add_development_dependency 'fakeweb'
  s.add_development_dependency 'nokogiri'
  s.add_development_dependency 'rake'
end
