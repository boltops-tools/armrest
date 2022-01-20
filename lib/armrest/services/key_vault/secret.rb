require "json"
require "net/http"
require "uri"

# az keyvault secret show --vault-name $VAULT --name "demo-dev-pass" | jq -r '.value'
module Armrest::Services::KeyVault
  class Secret < Base
    # Using Azure REST API since the old gem doesnt support secrets https://github.com/Azure/azure-sdk-for-ruby
    # https://docs.microsoft.com/en-us/rest/api/keyvault/get-secret/get-secret
    def show(options={})
      name = options[:name]
      @vault = options[:vault] || @options[:vault] || ENV['ARMREST_VAULT'] || self.class.vault
      version = "/#{version}" if @options[:version]
      begin
        resp = api.get("/secrets/#{name}#{version}")
      rescue SocketError => e
        if e.message.include?("vault.azure.net")
          message = "WARN: Vault not found. Vault: #{@vault}"
          logger.info message.color(:yellow)
          return message
        else
          raise
        end
      end

      case resp.code.to_s
      when /^2/
        data = JSON.load(resp.body)
        data['value']
      else
        message = standard_error_message(resp)
        logger.info "WARN: #{message}".color(:yellow)
        return message
      end
    end
  end
end
