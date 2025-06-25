module Armrest::Api::Auth
  class Base < Armrest::Api::Base
    # Add OIDC to the auth provider chain
    def self.providers
      @providers ||= [Login, OIDC, MSI, AZ]
    end
  end
end
