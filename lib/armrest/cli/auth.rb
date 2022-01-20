class Armrest::CLI
  class Auth
    def initialize(options={})
      @options = options
    end

    def run
      provider = Armrest::Auth.new(@options).provider
      if provider
        puts JSON.pretty_generate(provider.creds)
      else
        puts "Unable to authenticate"
      end
    end
  end
end
