module Armrest::Api
  module Mods
    include Armrest::Logging
    include HandleResponse
    include Settings
    include VERSION
  end
end
