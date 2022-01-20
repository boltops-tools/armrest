module Armrest::Services
  class Base
    include Armrest::Api::Mods
    extend Memoist

    def initialize(options={})
      @options = options
    end

  private
    def api
      Armrest::Api::Main.new
    end
    memoize :api
  end
end
