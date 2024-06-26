# url_resolver

[![CircleCI](https://circleci.com/gh/tenjin/url_resolver.svg?style=svg)](https://circleci.com/gh/tenjin/url_resolver)

url_resolver follows redirects to resolve URLs. It's pretty alright.

### Installation

Gemfile:

    gem 'url_resolver'

Rubygems:

    gem install url_resolver

### Usage

```ruby
UrlResolver.resolve('http://www.google.com')
# => "http://www.google.com"

UrlResolver.resolve('http://analytics.google.com')
# => "http://www.google.com/analytics/"
```

### Configuration

url_resolver supports caching in case you're planning on hitting a lot of the same URLs over and over and over and over again.

It also supports using a custom list of errors to ignore.

```ruby
UrlResolver.configure do |config|
  config.cache = Redis.new # default: nil
  config.cache_failures = true # default: true
  config.user_agent = 'Custom User-Agent' # default: 'Ruby'
  config.errors_to_ignore << MyModule::MyError
  config.timeout = 60
end
```

or 

```ruby
UrlResolver.configuration.cache = Redis.new
UrlResolver.configuration.cache_failures = true
UrlResolver.configuration.user_agent = 'Custom User-Agent'
UrlResolver.configuration.errors_to_ignore << MyModule::MyError
UrlResolver.configuration.timeout = 60
```

### Changelog

##### 0.3.2
+ Use ruby 2.7.7 for building
+ Fix compatability with ruby >= 2.6

##### 0.3.1
+ Update rest-client to 2.0.2
+ Add http timeout configuration
+ Handle multi-hop redirects that end in unreachable urls (non-http, unknown hostnames)

##### 0.2.0
+ Update rest-client to 1.8

##### 0.1.1
+ Handle redirects that resolve to nonstandard protocols

##### 0.1.0
+ Initial release

### Todo
+ configurable cache timeouts + keys
+ non-Redis caches
+ more configurable failure handling (request timeouts, bad URLs, etc)
+ support non-RestClient http clients
+ relax and enjoy life
