module Armrest::Services
  class BlobContainer < Base
    def initialize(options={})
      super
      @storage_account = options[:storage_account]
    end

    # https://docs.microsoft.com/en-us/rest/api/storagerp/blob-containers/get
    # GET https://management.azure.com/subscriptions/{subscriptionId}/resourceGroups/{resourceGroupName}/providers/Microsoft.Storage/storageAccounts/{accountName}/blobServices/default/containers/{containerName}?api-version=2021-04-01
    def get(attrs={})
      name = attrs[:name]
      path = "subscriptions/#{subscription_id}/resourceGroups/#{group}/providers/Microsoft.Storage/storageAccounts/#{@storage_account}/blobServices/default/containers/#{name}"
      api.get(path)
    end

    def exist?(attrs={})
      resp = get(attrs)
      resp.code =~ /^20/
    end

    # https://docs.microsoft.com/en-us/rest/api/storagerp/blob-containers/create
    # PUT https://management.azure.com/subscriptions/{subscriptionId}/resourceGroups/{resourceGroupName}/providers/Microsoft.Storage/storageAccounts/{accountName}/blobServices/default/containers/{containerName}?api-version=2021-04-01
    def create(attrs={})
      name = attrs.delete(:name)
      path = "subscriptions/#{subscription_id}/resourceGroups/#{group}/providers/Microsoft.Storage/storageAccounts/#{@storage_account}/blobServices/default/containers/#{name}"
      api.put(path)
    end
  end
end
