require "azure_info"

module Armrest::Api
  module Settings
    def client_id
      @options[:client_id] || ENV['ARM_CLIENT_ID'] || ENV['AZURE_CLIENT_ID']
    end

    def client_secret
      @options[:client_secret] || ENV['ARM_CLIENT_SECRET'] || ENV['AZURE_CLIENT_SECRET']
    end

    def tenant_id
      @options[:tenant_id] || ENV['ARM_TENANT_ID'] || ENV['AZURE_TENANT_ID'] || AzureInfo.tenant_id
    end

    def resource
      @options[:resource] || "https://management.azure.com"
    end

    def subscription_id
      @options[:subscription_id] || ENV['ARM_SUBSCRIPTION_ID'] || ENV['AZURE_SUBSCRIPTION_ID'] || AzureInfo.subscription_id
    end

    def location
      @options[:location] || ENV['ARM_LOCATION'] || ENV['AZURE_LOCATION'] || AzureInfo.location
    end

    def group
      @options[:group] || ENV['ARM_GROUP'] || AzureInfo.group
    end

    def endpoint
      @options[:endpoint] || "https://management.azure.com"
    end
  end
end
