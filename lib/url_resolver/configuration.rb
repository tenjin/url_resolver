module UrlResolver
  class Configuration
    attr_accessor :cache_failures, :user_agent, :errors_to_ignore, :timeout
    attr_reader :cache, :url_cache

    DEFAULT_ERRORS_TO_IGNORE = [SocketError,
      Errno::ETIMEDOUT,
      Errno::ECONNREFUSED,
      Errno::ECONNRESET,
      RestClient::InternalServerError,
      RestClient::ServiceUnavailable,
      RestClient::BadRequest,
      RestClient::GatewayTimeout,
      RestClient::RequestTimeout,
      RestClient::NotFound,
      RestClient::BadGateway,
      RestClient::MethodNotAllowed,
      RestClient::Unauthorized,
      RestClient::Forbidden,
      RestClient::NotAcceptable,
      URI::InvalidURIError]

    def initialize
      @cache_failures = true
      @cache = nil
      @url_cache = Cache.new(@cache)
      @user_agent = 'Ruby'
      @errors_to_ignore = DEFAULT_ERRORS_TO_IGNORE
      @timeout = 5
    end
    
    def cache=(cache)
      @cache = cache
      @url_cache = Cache.new(@cache)
    end
  end
  
  def self.configuration
    @configuration ||= Configuration.new
  end

  def self.configure
    yield(configuration)
  end
end
