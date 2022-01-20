module Armrest::Api::Auth
  class Login < Base
    def endpoint
      "https://login.microsoftonline.com"
    end

    def creds
      url = "#{tenant_id}/oauth2/token"
      resp = get(url,
        grant_type: "client_credentials",
        client_id: client_id,
        client_secret: client_secret,
        resource: resource,
      )
      load_json(resp)
    end
  end
end
