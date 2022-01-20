class Armrest::CLI
  class BlobContainer < Armrest::Command
    class_option :storage_account, desc: "Storage account name"

    desc "get", "Check existence of blob container"
    long_desc Help.text("blob_container/get")
    def get(name)
      exist = Armrest::Services::BlobContainer.new(options).get(name: name)
      if exist
        puts "Blob container exists: #{name}"
      else
        puts "Blob container does not exist: #{name}"
      end
    end

    desc "create", "Create or update Blob container"
    long_desc Help.text("blob_container/create")
    def create(name)
      resp = Armrest::Services::BlobContainer.new(options).create(name: name)
      if resp.code == "201"
        puts "Blob container created: #{name}"
      else
        puts "Blob container unable to create: #{name}"
        puts "resp:"
        pp resp
      end
    end
  end
end
