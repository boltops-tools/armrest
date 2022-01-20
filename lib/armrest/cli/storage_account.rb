class Armrest::CLI
  class StorageAccount < Armrest::Command
    desc "check_name_availability", "Check availability of storage account"
    long_desc Help.text("storage_account/check_name_availability")
    def check_name_availability(name)
      result = Armrest::Services::StorageAccount.new(options).check_name_availability(name: name)
      if result.name_available
        puts "Storage account is available: #{name}"
      else
        puts "Storage account is not available: #{name}"
        pp result
      end
    end

    desc "create", "Create storage account"
    long_desc Help.text("storage_account/create")
    option :location, description: "location"
    option :tags, type: :hash, description: "--tags=name:bob age:8"
    def create(name)
      resp = Armrest::Services::StorageAccount.new(options).create(options.merge(name: name))
      puts "resp:"
      pp resp
      if resp.code == "202"
        puts "Storage account created: #{name}"
      elsif resp.code =~ /^20/
        puts "Storage account updated: #{name}"
      else
        puts "Storage account unable to create: #{name}"
      end
    end
  end
end
