module Armrest
  class Auth
    include Armrest::Logging

    def initialize(options = {})
      @options = options
    end

    def provider
      providers.each do |meth|
        provider = send(meth)
        if provider
          logger.debug "Resolved auth provider: #{provider}"
          return provider
        end
      end
      nil
    end

    private

    def providers
      if @options[:type]
        ["#{@options[:type]}_credentials"]
      else # full chain
        [
          :app_credentials,
          :oidc_credentials,
          :msi_credentials,
          :cli_credentials
        ]
      end
    end

    def app_credentials
      return unless ENV["ARM_CLIENT_ID"] || ENV["AZURE_CLIENT_ID"]
      return if %w[1 true yes].include?(ENV["ARM_USE_OIDC"])
      Armrest::Api::Auth::Login.new(@options)
    end

    def oidc_credentials
      return unless Armrest::Api::Auth::OIDC.configured?
      Armrest::Api::Auth::OIDC.new(@options)
    end

    def msi_credentials
      api = Armrest::Api::Auth::Metadata.new(@options)
      api if api.available?
    end

    def cli_credentials
      Armrest::Api::Auth::CLI.new(@options)
    end
  end
end
