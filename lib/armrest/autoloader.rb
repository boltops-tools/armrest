require "zeitwerk"

module Armrest
  class Autoloader
    class Inflector < Zeitwerk::Inflector
      def camelize(basename, _abspath)
        map = self.class.camelize_map
        map[basename.to_sym] || super
      end

      def self.camelize_map
        { cli: "CLI", msi: "MSI", version: "VERSION" }
      end
    end

    class << self
      def setup
        loader = Zeitwerk::Loader.new
        loader.inflector = Inflector.new
        loader.push_dir(File.dirname(__dir__)) # lib
        loader.setup
      end
    end
  end
end
