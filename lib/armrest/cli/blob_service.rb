class Armrest::CLI
  class BlobService < Armrest::Command
    class_option :storage_account, desc: "Storage account name"

    desc "get_properties", "Check existence of blob container"
    long_desc Help.text("blob_container/get_properties")
    def get_properties
      result = Armrest::Services::BlobService.new(options).get_properties
      puts JSON.pretty_generate(result)
    end

    desc "create", "Create or update Blob container"
    long_desc Help.text("blob_container/create")
    option :delete_retention_policy, type: :hash, desc: "days:7 enabled:true"
    option :container_delete_retention_policy, type: :hash, desc: "days:7 enabled:true"
    option :is_versioning_enabled, type: :boolean, desc: "Enables versioning"
    def set_properties
      props = options.dup
      props.delete(:storage_account)
      resp = Armrest::Services::BlobService.new(options).set_properties(props)
      puts "resp:"
      pp resp
    end
  end
end
