Gem::Specification.new do |s|
  s.name        = 'url_resolver'
  s.version     = '0.1.8'
  s.date        = '2014-10-23'
  s.summary     = "Url Resolver!"
  s.description = "Simple gem to follow redirects to resolve the destination of a URL. Caches results sometimes."
  s.authors     = ["Amir Manji"]
  s.email       = 'amanji75@gmail.com'
  s.files       =  Dir.glob("{bin,lib}/**/*")
  s.homepage    =
    'http://www.github.com/amirmanji/url_resolver'
  s.license       = 'MIT'
  s.add_runtime_dependency "rest-client", [ "1.6.7" ]
  s.add_development_dependency "rspec", [ "2.14.7" ]
end
