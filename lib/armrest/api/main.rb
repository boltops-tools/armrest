module Armrest::Api
  class Main < Base
    def headers
      {
        "Authorization" => authorization,
        "Content-Type" => "application/json",
      }
    end

    # cache key is the resource/audience. IE:
    # {
    #   "https://management.azure.com" => {...},
    #   "https://vault.azure.com" => {...},
    # }
    @@creds_cache = {}
    def authorization
      creds = @@creds_cache[resource]
      if creds && Time.now < Time.at(creds['expires_on'].to_i)
        return bearer_token(creds)
      end

      provider = Armrest::Auth.new(@options).provider
      if provider
        creds = provider.creds
        @@creds_cache[resource] = creds
        bearer_token(creds)
      end
    end

    def bearer_token(creds)
      "#{creds['token_type']} #{creds['access_token']}"
    end
  end
end
