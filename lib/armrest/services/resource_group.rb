module Armrest::Services
  class ResourceGroup < Base
    # https://docs.microsoft.com/en-us/rest/api/resources/resource-groups/check-existence
    # HEAD https://management.azure.com/subscriptions/{subscriptionId}/resourcegroups/{resourceGroupName}?api-version=2021-04-01
    def check_existence(attrs={})
      name = attrs[:name]
      path = "subscriptions/#{subscription_id}/resourcegroups/#{name}"
      resp = api.head(path)
      resp.code == "204" # means it exists
    end

    # https://docs.microsoft.com/en-us/rest/api/resources/resource-groups/create-or-update
    # PUT https://management.azure.com/subscriptions/{subscriptionId}/resourcegroups/{resourceGroupName}?api-version=2021-04-01
    def create_or_update(attrs={})
      name = attrs.delete(:name)
      # https://docs.microsoft.com/en-us/rest/api/resources/resource-groups/create-or-update#request-body
      attrs[:location] ||= location
      attrs[:tags] = attrs[:tags] if attrs[:tags]
      path = "subscriptions/#{subscription_id}/resourcegroups/#{name}"
      api.put(path, attrs)
    end
  end
end
