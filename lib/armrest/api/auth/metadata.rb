# GET 'https://169.254.169.254/metadata/identity/oauth2/token?api-version=2018-02-01&resource=https://management.azure.com/' HTTP/1.1 Metadata: true
module Armrest::Api::Auth
  class Metadata < Base
    def initialize(options={})
      @options = options
    end

    def creds
      url = "metadata/identity/oauth2/token?" + Rack::Utils.build_query(query_params)
      resp = get(url)
      load_json(resp)
    end

    @@available = nil
    def available?
      return false if ENV['ARMREST_DISABLE_MSI']
      return @@available unless @@available.nil?
      url = "metadata/instance"
      resp = nil
      with_open_timeout(0.5) do
        resp = get(url)
      end
      @@available = resp.code == "200"
    rescue Net::OpenTimeout => e
      logger.debug "#{e.class}: #{e.message}"
      false
    end

    def query_params
      params = { resource: resource }
      params[:client_id] = client_id if client_id
      params[:object_id] = object_id if @options[:object_id]
      params[:msi_res_id] = msi_res_id if @options[:msi_res_id]
      params
    end

    # interface method
    def endpoint
      "http://169.254.169.254"
    end

    # interface method
    def headers
      { Metadata: true }
    end

    def api_version
      "2021-10-01"
    end
  end
end
