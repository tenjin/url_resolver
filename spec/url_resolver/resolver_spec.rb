require 'spec_helper'

describe UrlResolver::Resolver do
  subject { UrlResolver::Resolver.new }
  
  describe '#resolve' do
    before(:each) do
      stub_request(:head, 'http://www.google.com').to_return(status: 302, headers: { location: 'http://www.boogle.com' })
      stub_request(:head, 'http://www.boogle.com').to_return(status: 200)
    end
    
    it 'returns the URL that RestClient finds' do
      expect(subject.resolve('http://www.google.com')).to eq('http://www.boogle.com')
    end
    
    it 'returns cached URLs' do
      allow(subject.cache).to receive(:get_url) { 'http://www.doogle.com' }
      expect(subject.resolve('http://www.google.com')).to eq('http://www.doogle.com')
    end
    
    it 'caches found URLs' do
      expect(subject.cache).to receive(:set_url).with(anything, 'http://www.boogle.com')
      subject.resolve('http://www.google.com')
    end
    
    it 'raises an error with the URL if an unknown exception occurs' do
      stub_request(:head, 'http://www.google.com').and_raise(FakeException)
      expect{ subject.resolve('http://www.google.com') }
        .to raise_error(UrlResolver::UrlResolverError, /http:\/\/www.google.com/)
    end
    
    describe 'with an expected exception' do
      before(:each) do
        stub_request(:head, 'http://www.google.com').and_raise(SocketError)
      end
      
      it 'returns the original URL' do
        expect(subject.resolve('http://www.google.com')).to eq('http://www.google.com')
      end
      
      it 'caches the original URL as the result' do
        expect(subject.cache).to receive(:set_url).with(anything, 'http://www.google.com')
        subject.resolve('http://www.google.com')
      end
      
      describe 'if cache_failures is false' do
        before(:each) do
          expect(UrlResolver.configuration).to receive(:cache_failures) { false }
        end
        
        it 'should not cache the original URL as the result' do
          expect(subject.cache).to_not receive(:set_url)
          subject.resolve('http://www.google.com')
        end
      end
    end

    it 'should resolve incomplete redirects to non-http' do
      first_url = 'https://legit.com/path'
      second_url = 'market://search?q=com.bundle.id'
      stub_request(:head, first_url).to_return(status: 302, headers: { location: second_url })
      expect(subject.resolve(first_url)).to eq(second_url)
    end

    it 'should resolve incomplete multi-redirects to non-http' do
      first_url = 'https://legit.com/path'
      second_url = 'https://legit.com/another'
      third_url = 'market://search?q=com.bundle.id'
      stub_request(:head, first_url).to_return(status: 302, headers: { location: second_url })
      stub_request(:head, second_url).to_return(status: 302, headers: { location: third_url })
      expect(subject.resolve(first_url)).to eq(third_url)
    end

    it 'should resolve incomplete redirects to http' do
      first_url = 'https://legit.com/path'
      second_url = 'https://search?q=com.bundle.id'
      stub_request(:head, first_url).to_return(status: 302, headers: { location: second_url })
      stub_request(:head, second_url).to_raise(SocketError.new('getaddrinfo: nodename nor servname provided, or not known'))
      expect(subject.resolve(first_url)).to eq(second_url)
    end

    describe 'URL encoding' do
      it 'double-encodes path segments that are already encoded' do
        # URL with already encoded segments - ERB::Util.url_encode will double-encode
        url_with_encoded = 'https://example.com/path%20with%20spaces/segment%20encoded'
        # After encoding: %20 becomes %2520 (double-encoded)
        encoded_url = 'https://example.com/path%2520with%2520spaces/segment%2520encoded'
        stub_request(:head, encoded_url).to_return(status: 200)
        
        # The URL should be double-encoded before being sent to RestClient
        expect(RestClient::Request).to receive(:execute).with(
          hash_including(url: encoded_url)
        ).and_call_original
        
        subject.resolve(url_with_encoded)
      end

      it 're-encodes query parameters' do
        url_with_query = 'https://example.com/path?param1=value+with+spaces&param2=already%20encoded'
        # Query should be re-encoded: decode then encode
        # "value+with+spaces" becomes "value with spaces" then "value%20with%20spaces"
        # "already%20encoded" becomes "already encoded" then "already%20encoded"
        stub_request(:head, /https:\/\/example\.com\/path\?/).to_return(status: 200)
        
        subject.resolve(url_with_query)
      end

      it 'handles URLs without paths' do
        url_no_path = 'https://example.com?query=value'
        stub_request(:head, /https:\/\/example\.com\?/).to_return(status: 200)
        
        subject.resolve(url_no_path)
      end

      it 'handles URLs without query parameters' do
        url_no_query = 'https://example.com/path/segment'
        encoded_url = 'https://example.com/path/segment'
        stub_request(:head, encoded_url).to_return(status: 200)
        
        subject.resolve(url_no_query)
      end

      it 'handles URLs with empty path segments' do
        url_empty_segments = 'https://example.com//path//segment'
        encoded_url = 'https://example.com//path//segment'
        stub_request(:head, encoded_url).to_return(status: 200)
        
        subject.resolve(url_empty_segments)
      end

      it 'double-encodes path segments that contain encoded characters' do
        # URL with already encoded segments - will be double-encoded
        url = 'https://example.com/path%20with%20spaces/another%20segment'
        # After encoding: %20 becomes %2520
        encoded_url = 'https://example.com/path%2520with%2520spaces/another%2520segment'
        stub_request(:head, encoded_url).to_return(status: 200)
        
        expect(RestClient::Request).to receive(:execute).with(
          hash_including(url: encoded_url)
        ).and_call_original
        
        subject.resolve(url)
      end

      it 'double-encodes URLs with unicode characters in path' do
        # URL with unicode that is already encoded - will be double-encoded
        url = 'https://example.com/caf%C3%A9/resum%C3%A9'
        # After encoding: %C3%A9 becomes %25C3%25A9
        encoded_url = 'https://example.com/caf%25C3%25A9/resum%25C3%25A9'
        stub_request(:head, encoded_url).to_return(status: 200)
        
        subject.resolve(url)
      end
    end
  end
  
end
