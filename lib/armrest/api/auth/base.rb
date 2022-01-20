module Armrest::Api::Auth
  class Base < Armrest::Api::Base
    def initialize(options={})
      super
      @camelize_request_data = false
    end
  end
end
