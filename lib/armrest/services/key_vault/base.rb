module Armrest::Services::KeyVault
  class Base < Armrest::Services::Base
    class Error < StandardError; end
    class VaultNotFoundError < Error; end
    class VaultNotConfiguredError < Error; end

    extend Memoist
    cattr_accessor :vault

  private
    def api
      check_vault_configured!
      vault_subdomain = @vault.downcase
      endpoint = "https://#{vault_subdomain}.vault.azure.net"
      logger.debug "Azure vault endpoint #{endpoint}"
      Armrest::Api::Main.new(
        api_version: "7.1",
        endpoint: endpoint,
        resource: "https://vault.azure.net",
      )
    end
    memoize :api

    def check_vault_configured!
      return if @vault
      logger.error "ERROR: Vault has not been configured.".color(:red)
      logger.error <<~EOL
        Please configure the Azure KeyVault you want to use.  Examples:

        1. env var

            ARMREST_VAULT=demo-vault

        2. class var

            Armrest::KeyVault::Secret.vault = "demo-vault"
      EOL
      raise VaultNotConfiguredError.new
    end

    # Secret error handling: 1. network 2. json parse 3. missing secret
    #
    # Azure API responses with decent error message when
    #   403 Forbidden - KeyVault Access Policy needs to be set up
    #   404 Not Found - Secret name is incorrect
    #
    def standard_error_message(resp)
      data = JSON.load(resp.body)
      data['error']['message']
    rescue JSON::ParserError
      resp.body
    end
  end
end
