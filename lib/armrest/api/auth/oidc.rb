module Armrest::Api::Auth
  # OIDC authentication provider for Azure
  class OIDC < Base
    include Armrest::Logging

    # Check if OIDC authentication is configured via environment variables
    def self.configured?
      # Check for ARM_USE_OIDC explicit flag
      use_oidc = ENV['ARM_USE_OIDC'] || ENV['AZURE_USE_OIDC']
      use_oidc = use_oidc.downcase if use_oidc
      case use_oidc
      when 'false' then return false
      when 'true'  then return true
      when nil
        # Check for direct OIDC token
        return true if ENV['ARM_OIDC_TOKEN'] || ENV['AZURE_OIDC_TOKEN']
        return true if ENV['ARM_OIDC_TOKEN_FILE_PATH'] || ENV['AZURE_OIDC_TOKEN_FILE_PATH']

        # Check for GitHub Actions OIDC credentials
        return true if ENV['ACTIONS_ID_TOKEN_REQUEST_URL'] && ENV['ACTIONS_ID_TOKEN_REQUEST_TOKEN']
        return true if ENV['ARM_OIDC_REQUEST_URL'] && ENV['ARM_OIDC_REQUEST_TOKEN']

        # Check for Azure DevOps OIDC credentials
        return true if ENV['SYSTEM_OIDCREQUESTURI'] && ENV['SYSTEM_ACCESSTOKEN']

        false
      else
        logger.warn "Unrecognized OIDC flag value: #{use_oidc}"
      end
    end

    # Initialize with required Azure credentials
    def initialize(options = {})
      super
      @client_id = options[:client_id] || ENV['ARM_CLIENT_ID'] || ENV['AZURE_CLIENT_ID']
      @tenant_id = options[:tenant_id] || ENV['ARM_TENANT_ID'] || ENV['AZURE_TENANT_ID']
      @subscription_id = options[:subscription_id] || ENV['ARM_SUBSCRIPTION_ID'] || ENV['AZURE_SUBSCRIPTION_ID']
      
      # Service connection ID for Azure DevOps
      @service_connection_id = options[:service_connection_id] || 
                                ENV['ARM_ADO_PIPELINE_SERVICE_CONNECTION_ID'] || 
                                ENV['ARM_OIDC_AZURE_SERVICE_CONNECTION_ID']
      
      # Debug logging
      logger.debug "Initialized OIDC Auth Provider with client_id: #{@client_id}, tenant_id: #{@tenant_id}"
    end

    # Get the authentication token
    def token
      @token ||= acquire_token
    end

    # Get the credentials
    def creds
      return @creds if @creds
      token_info = acquire_token
      @creds = {
        'access_token' => token_info['access_token'],
        'expires_on'   => (Time.now.to_i + token_info['expires_in'].to_i).to_s,
        'token_type'   => token_info['token_type'] || 'Bearer'
      }
    end

    private

    # Acquire token using OIDC flow
    def acquire_token
      # First, try to get the OIDC token from various sources
      oidc_token = get_oidc_token
      
      unless oidc_token
        raise Armrest::Error, "Failed to acquire OIDC token from any source"
      end

      # Exchange OIDC token for an Azure access token
      exchange_token_for_access_token(oidc_token)
    end

    # Get OIDC token from various sources
    def get_oidc_token
      # Try direct token
      return ENV['ARM_OIDC_TOKEN'] || ENV['AZURE_OIDC_TOKEN'] if ENV['ARM_OIDC_TOKEN'] || ENV['AZURE_OIDC_TOKEN']
      
      # Try token file
      token_file = ENV['ARM_OIDC_TOKEN_FILE_PATH'] || ENV['AZURE_OIDC_TOKEN_FILE_PATH']
      if token_file && File.exist?(token_file)
        begin
          return File.read(token_file).strip
        rescue => e
          logger.error "Failed to read token file: #{e.message}"
          return nil
        end
      end
      
      # Try GitHub Actions
      if ENV['ACTIONS_ID_TOKEN_REQUEST_URL'] && ENV['ACTIONS_ID_TOKEN_REQUEST_TOKEN']
        return request_github_actions_token
      end
      
      # Try custom request URL/token
      if ENV['ARM_OIDC_REQUEST_URL'] && ENV['ARM_OIDC_REQUEST_TOKEN']
        return request_token_from_provider(
          ENV['ARM_OIDC_REQUEST_URL'],
          ENV['ARM_OIDC_REQUEST_TOKEN']
        )
      end
      
      # Try Azure DevOps
      if ENV['SYSTEM_OIDCREQUESTURI'] && ENV['SYSTEM_ACCESSTOKEN']
        return request_token_from_provider(
          ENV['SYSTEM_OIDCREQUESTURI'],
          ENV['SYSTEM_ACCESSTOKEN']
        )
      end
      
      nil
    end

    # Request token from GitHub Actions
    def request_github_actions_token
      request_token_from_provider(
        ENV['ACTIONS_ID_TOKEN_REQUEST_URL'],
        ENV['ACTIONS_ID_TOKEN_REQUEST_TOKEN']
      )
    end

    # Generic function to request a token from a provider
    def request_token_from_provider(url, token)
      require 'net/http'
      require 'json'
      require 'uri'
      
      uri = URI.parse(url)
      unless uri.scheme == 'https'
        logger.error "Insecure request URL detected: #{url}"
        return nil
      end
      
      request = Net::HTTP::Get.new(uri)
      request['Authorization'] = "Bearer #{token}"
      request['Accept'] = 'application/json'
      
      response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: uri.scheme == 'https') do |http|
        http.request(request)
      end
      
      if response.is_a?(Net::HTTPSuccess)
        json_response = JSON.parse(response.body)
        return json_response['value']
      else
        logger.error "Failed to get OIDC token: #{response.code} - #{response.body}"
        nil
      end
    end

    # Exchange OIDC token for Azure access token
    def exchange_token_for_access_token(oidc_token)
      require 'net/http'
      require 'json'
      require 'uri'
      
      token_endpoint = "https://login.microsoftonline.com/#{@tenant_id}/oauth2/v2.0/token"
      
      uri = URI.parse(token_endpoint)
      request = Net::HTTP::Post.new(uri)
      request['Content-Type'] = 'application/x-www-form-urlencoded'
      
      # Prepare form data
      form_data = {
        'client_id' => @client_id,
        'client_assertion_type' => 'urn:ietf:params:oauth:client-assertion-type:jwt-bearer',
        'client_assertion' => oidc_token,
        'grant_type' => 'client_credentials',
        'scope' => 'https://management.azure.com/.default'
      }
      
      # Add service connection ID for Azure DevOps if available
      form_data['service_connection_id'] = @service_connection_id if @service_connection_id
      
      request.set_form_data(form_data)
      
      # Debug logging
      logger.debug "Exchanging OIDC token for access token with endpoint: #{token_endpoint}"
      
      response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: uri.scheme == 'https') do |http|
        http.request(request)
      end
      
      if response.is_a?(Net::HTTPSuccess)
        json_response = JSON.parse(response.body)
        logger.debug "Received access token (expires in #{json_response['expires_in']} seconds)"
        # Return the entire JSON so the caller can read token_type, expires_in, etc.
        return json_response
      else
        error_message = "Failed to exchange OIDC token: #{response.code} - #{response.body}"
        logger.error error_message
        raise Armrest::Error, error_message
      end
    end
  end
end