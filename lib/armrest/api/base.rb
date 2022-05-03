require 'net/http'
require 'rack'

module Armrest::Api
  class Base
    extend Memoist
    include Mods

    def initialize(options={})
      @options = options
    end

    HTTP_WRITE_METHODS = %w[post patch put delete]
    HTTP_READ_METHODS = %w[get head]
    methods = HTTP_WRITE_METHODS + HTTP_READ_METHODS
    methods.each do |meth|
      define_method(meth) do |path, data={}|
        request("Net::HTTP::#{meth.camelize}".constantize, path, data)
      end
      # IE:
      # def get(path, data={})
      #   request(Net::HTTP::Get, path, data)
      # end
    end

    # Always translate raw json response to ruby Hash
    def request(klass, path, data={})
      path = standarize_path(path)
      url = url(path)
      req = build_request(klass, path, data)
      http = http(url)
      meth = klass.to_s.split('::').last.underscore
      logger.debug "#{meth.upcase} #{url}".color(:yellow)
      # logger.debug "req['Authorization'] #{req['Authorization']}"

      resp = send_request(http, req)

      logger.debug "resp #{resp}"
      logger.debug "resp.code #{resp.code}"
      logger.debug "resp.body #{resp.body}"

      if HTTP_WRITE_METHODS.include?(meth) && resp.code !~ /^20/
        raise Armrest::Error.new(resp)
      end

      resp
    end

    MAX_RETRIES = (ENV['ARMREST_MAX_RETRIES'] || 3).to_i
    def send_request(http, req)
      retries = 0
      resp = http.request(req) # send request
      retry_codes = [/^5/, "429"]
      retry_code_detected = retry_codes.detect { |code| resp.code.match(code) }
      if retry_code_detected && retries < MAX_RETRIES
        retries += 1
        delay = 2 ** retries
        logger.debug "retries #{retries} sleep #{delay} and will retry."
        sleep delay
        resp = http.request(req) # send request
      end
      resp
    end

    def build_request(klass, path, data={})
      req = klass.new(path) # url includes query string and uri.path does not, must used url
      set_headers!(req)

      logger.debug "build_request data #{data}"

      # Note: Need to use to_s for case statement to work right
      case klass.to_s.split('::').last.underscore
      when "delete", "patch",  "post",  "put"
        text = JSON.dump(data)
        req.body = text
        req.content_length = text.bytesize
      when "get"
        req.set_form_data(data) if data && !data.empty?
      end

      req
    end

    def standarize_path(path)
      path = "/#{path}" unless path.starts_with?('/')
      path = append_api_version(path)
    end

    def append_api_version(path)
      separator = path.include?('?') ? '&' : '?'
      path + separator + "api-version=#{api_version}"
    end

    def set_headers!(req)
      headers.each do |k,v|
        req[k.to_s] = v.to_s
      end
    end

    # interface method
    def headers
      {}
    end

    def http(url)
      uri = URI(url)
      http = Net::HTTP.new(uri.host, uri.port)
      http.open_timeout = @open_timeout || 30
      http.read_timeout = @read_timeout || 30
      http.use_ssl = true if uri.scheme == 'https'
      http
    end
    memoize :http

    def with_open_timeout(value)
      saved, @open_timeout = @open_timeout, value
      yield
      @open_timeout = saved
    end

    # interface method. API endpoint does not include the /. IE: https://login.microsoftonline.com
    def url(path)
      "#{endpoint}#{path}"
    end
  end
end
