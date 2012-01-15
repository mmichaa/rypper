# encoding: UTF-8

require 'net/http'
require 'uri'

module Net
  class HTTPClient
    class << self
      def storage
        @storage ||= {}
      end

      def from_storage(host, port=80, renew=false)
        if self.storage.has_key?(host) and not renew
          connection = self.storage[host]
        else
          connection = self.new(host, port)
          self.storage[host] = connection
        end
        return connection
      end
    end

    attr_reader :host, :port, :timeout
    attr_writer :keep_alive
    attr_accessor :user_agent

    def initialize(host, port=80, timeout=15)
      @host = host.to_s.strip
      @port = port.to_i
      @keep_alive = true
      @timeout = timeout.to_i
      @user_agent = "Net::HTTPClient/0.1 (Ruby #{RUBY_VERSION})"
      @http = Net::HTTP.new(self.host, self.port)
      @http.read_timeout = self.timeout
      @http.open_timeout = self.timeout
    end

    def keep_alive?
      @keep_alive ? true : false
    end

    def get(path, header={}, options={})
      uri = path.is_a?(URI) ? path : self.to_uri(path)
      header['Accept'] ||= '*/*'
      header['Connection'] ||= (self.keep_alive? ? 'Keep-Alive' : 'Close')
      header['Referer'] = uri.to_s if options[:referer_self]
      header['User-Agent'] ||= self.user_agent
      @http.start unless @http.started?
      response = nil
      begin
        response = @http.request_get(uri.path, header)
      rescue EOFError
        @http = Net::HTTP.new(self.host, self.port)
        @http.start
        response = @http.request_get(uri.path, header)
      end
      if response.is_a?(Net::HTTPRedirection) && options[:follow_redirects]
        uri_redirect = URI.parse(response['Location'])
        header_redirect = options[:follow_with_header] ? header : options[:follow_header] || {}
        options_redirect = options[:follow_with_options] ? options : options[:follow_options] || {}
        options_redirect['Referer'] ||= uri.to_s 
        connection = self.class.from_storage(uri_redirect.host, uri_redirect.port)
        response = connection.get(uri_redirect, header_redirect, options_redirect)
      end
      return response
    end

    def to_uri(path=nil)
      return URI::HTTP.build({:host => self.host, :port => self.port, :path => path})
    end
  end
end