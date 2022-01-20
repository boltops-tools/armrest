class Armrest::CLI
  class Secret < Armrest::Command
    desc "show", "Runs show operations."
    long_desc Help.text("secret/show")
    option :version, aliases: %w[v], description: "secret version"
    option :vault, description: "vault name"
    def show(name)
      puts Armrest::Services::KeyVault::Secret.new(options).show(name: name)
    end
  end
end
