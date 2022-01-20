module Armrest::Services
  class BlobService < Base
    def initialize(options={})
      super
      @storage_account = options[:storage_account]
    end

    # https://docs.microsoft.com/en-us/rest/api/storagerp/blob-services/get-service-properties
    # GET https://management.azure.com/subscriptions/{subscriptionId}/resourceGroups/{resourceGroupName}/providers/Microsoft.Storage/storageAccounts/{accountName}/blobServices/default?api-version=2021-04-01
    def get_properties
      path = "subscriptions/#{subscription_id}/resourceGroups/#{group}/providers/Microsoft.Storage/storageAccounts/#{@storage_account}/blobServices/default"
      resp = api.get(path)
      load_json(resp)
    end

    # https://docs.microsoft.com/en-us/rest/api/storagerp/blob-services/set-service-properties
    # PUT https://management.azure.com/subscriptions/{subscriptionId}/resourceGroups/{resourceGroupName}/providers/Microsoft.Storage/storageAccounts/{accountName}/blobServices/default?api-version=2021-04-01
    def set_properties(props)
      props = props.to_h.deep_symbolize_keys
      data = { properties: props }
      path = "subscriptions/#{subscription_id}/resourceGroups/#{group}/providers/Microsoft.Storage/storageAccounts/#{@storage_account}/blobServices/default"
      api.put(path, data)
    end
  end
end
