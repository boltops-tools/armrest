module Armrest::Api
  module VERSION
    # vault uses 7.1
    def api_version
      @options[:api_version] || "2021-04-01"
    end
  end
end
