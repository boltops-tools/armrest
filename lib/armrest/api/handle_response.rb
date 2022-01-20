require "hashie"

module Armrest::Api
  module HandleResponse
    def load_json(resp)
      if ok?(resp.code)
        data = JSON.load(resp.body).deep_transform_keys(&:underscore)
        Response.new(data)
      else
        logger.info "Error: Non-successful http response status code: #{resp.code}"
        logger.info "headers: #{resp.each_header.to_h.inspect}"
        raise "Azure API called failed"
      end
    end

    # Note: 422 is Unprocessable Entity. This means an invalid data payload was sent.
    # We want that to error and raise
    def ok?(http_code)
      http_code =~ /^20/ ||
      http_code =~ /^40/
    end
  end
end
