$stdout.sync = true unless ENV["ARMREST_STDOUT_SYNC"] == "0"

$:.unshift(File.expand_path("../", __FILE__))

require "armrest/autoloader"
Armrest::Autoloader.setup

require "active_support"
require "active_support/core_ext/string"
require "memoist"
require "rainbow/ext/string"

module Armrest
  class Error < StandardError; end
end
