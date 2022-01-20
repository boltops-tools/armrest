class Armrest::CLI
  class ResourceGroup < Armrest::Command
    desc "check_existence", "Check existence of resource group"
    long_desc Help.text("resource_group/check_existence")
    def check_existence(name)
      exist = Armrest::Services::ResourceGroup.new(options).check_existence(name: name)
      if exist
        puts "Resource group exists: #{name}"
      else
        puts "Resource group does not exist: #{name}"
      end
    end

    desc "create_or_update", "Create or update resource group"
    long_desc Help.text("resource_group/create_or_update")
    option :location, description: "location"
    option :tags, type: :hash, description: "--tags=name:bob age:8"
    def create_or_update(name)
      resp = Armrest::Services::ResourceGroup.new(options).create_or_update(options.merge(name: name))
      if resp.code == "201"
        puts "Resource group created: #{name}"
      else
        puts "Resource group unable to create: #{name}"
        puts "resp:"
        pp resp
      end
    end
  end
end
