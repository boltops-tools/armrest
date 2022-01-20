module Armrest::Services
  class StorageAccount < Base
    # https://docs.microsoft.com/en-us/rest/api/storagerp/storage-accounts/check-name-availability
    # POST https://management.azure.com/subscriptions/{subscriptionId}/providers/Microsoft.Storage/checkNameAvailability?api-version=2021-04-01
    def check_name_availability(attrs={})
      name = attrs[:name]
      path = "subscriptions/#{subscription_id}/providers/Microsoft.Storage/checkNameAvailability"
      attrs = {
        name: name,
        type: "Microsoft.Storage/storageAccounts",
      }
      res = api.post(path, attrs)
      load_json(res)
    end

    # https://docs.microsoft.com/en-us/rest/api/storagerp/storage-accounts/create
    # PUT https://management.azure.com/subscriptions/{subscriptionId}/resourceGroups/{resourceGroupName}/providers/Microsoft.Storage/storageAccounts/{accountName}?api-version=2021-04-01
    # Note there's an update api also but PUT to create will also update. So just implementing create.
    def create(attrs={})
      name = attrs.delete(:name)
      # https://docs.microsoft.com/en-us/rest/api/storagerp/storage-accounts/create#request-body
      attrs[:kind] ||= "StorageV2"
      attrs[:location] ||= location
      attrs[:sku] ||= {
        name: "Standard_RAGRS", # default according to az storage account create --help
        tier: "Standard",
      }
      attrs[:properties] ||= {
        allow_blob_public_access: false
      }
      path = "subscriptions/#{subscription_id}/resourceGroups/#{group}/providers/Microsoft.Storage/storageAccounts/#{name}"
      resp = api.put(path, attrs)
    end
  end
end
