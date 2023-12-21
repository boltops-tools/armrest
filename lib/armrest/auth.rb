require "json"

module Armrest
  class Auth
    include Armrest::Logging

    def initialize(options={})
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

    def creds
      data = get_access_token
      data.deep_transform_keys { |k| k.camelize(:lower) } # to normalize the structure to the other classes
    end

  private
    def providers
      if @options[:type]
        ["#{@options[:type]}_credentials"]
      else # full chain
        [
          :app_credentials,
          :msi_credentials,
          :cli_credentials,
        ]
      end
    end

    def app_credentials
      return unless ENV['ARM_CLIENT_ID'] || ENV['AZURE_CLIENT_ID']
      Armrest::Api::Auth::Login.new(@options)
    end

    def msi_credentials
      api = Armrest::Api::Auth::Metadata.new(@options)
      api if api.available?
    end

    def cli_credentials
      Armrest::Api::Auth::CLI.new(@options)
    end

    def get_access_token
      command = "az account get-access-token -o json"
      logger.debug "command: #{command}"
      out = `#{command}`
      if $?.success?
        JSON.load(out)
      else
        raise CliError, "Error acquiring token from the Azure az CLI"
      end
    rescue
      raise JSON::ParserError, 'Error parsing token from the Azure az CLI'
    end
  end
end
