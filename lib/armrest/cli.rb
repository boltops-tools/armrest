module Armrest
  class CLI < Command
    class_option :verbose, type: :boolean
    class_option :noop, type: :boolean

    desc "blob_container SUBCOMMAND", "blob_container subcommands"
    long_desc Help.text(:blob_container)
    subcommand "blob_container", BlobContainer

    desc "blob_service SUBCOMMAND", "blob_service subcommands"
    long_desc Help.text(:blob_service)
    subcommand "blob_service", BlobService

    desc "resource_group SUBCOMMAND", "resource_group subcommands"
    long_desc Help.text(:resource_group)
    subcommand "resource_group", ResourceGroup

    desc "secret SUBCOMMAND", "secret subcommands"
    long_desc Help.text(:secret)
    subcommand "secret", Secret

    desc "storage_account SUBCOMMAND", "storage_account subcommands"
    long_desc Help.text(:storage_account)
    subcommand "storage_account", StorageAccount

    desc "auth [TYPE]", "Auth to Azure API. When TYPE is not provided, the full credentials chain is checked. Available TYPEs: app, msi, cli, oidc."
    long_desc Help.text(:auth)
    def auth(type=nil)
      Auth.new(options.merge(type: type)).run
    end

    desc "completion *PARAMS", "Prints words for auto-completion."
    long_desc Help.text(:completion)
    def completion(*params)
      Completer.new(CLI, *params).run
    end

    desc "completion_script", "Generates a script that can be eval to setup auto-completion."
    long_desc Help.text(:completion_script)
    def completion_script
      Completer::Script.generate
    end

    desc "version", "prints version"
    def version
      puts VERSION
    end
  end
end
