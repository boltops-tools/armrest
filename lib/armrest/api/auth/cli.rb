require "json"

#
# az account get-access-token : Get a token for utilities to access Azure.
#         The token will be valid for at least 5 minutes with the maximum at 60 minutes. If the
#         subscription argument isn't specified, the current account is used.
#
# Arguments
#     --resource         : Azure resource endpoints. Default to Azure Resource Manager.
#     --resource-type    : Type of well-known resource.  Allowed values: aad-graph, arm, batch, data-
#                         lake, media, ms-graph, oss-rdbms.
#     --subscription -s  : Name or ID of subscription.
#     --tenant -t        : Tenant ID for which the token is acquired. Only available for user and
#                         service principal account, not for MSI or Cloud Shell account.
module Armrest::Api::Auth
  class CLI < Base
    class Error < StandardError; end
    class CliError < Error; end

    def creds
      data = get_access_token
      data.deep_transform_keys { |k| k.underscore } # to normalize the structure to the other classes
    end

    # Looks like az account get-access-token caches the toke in ~/.azure/accessTokens.json
    # and will update it only when it expires. So dont think we need to handle caching
    def get_access_token
      command = "az account get-access-token -o json --resource #{resource}"
      logger.debug "command: #{command}"
      out = `#{command}`
      JSON.load(out)
    rescue
      raise CliError, 'Error acquiring token from the Azure az CLI'
    end
  end
end
