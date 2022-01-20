module Armrest
  module Logging
    @@logger = nil
    def logger
      @@logger ||= default_logger
    end

    def logger=(v)
      @@logger = v
    end

    # Note the Armrest logger on debug is pretty verbose so think it may be better
    # to not assign the Armrest::Logging.logger = Terraspace.logger
    def default_logger
      logger = Armrest::Logger.new($stderr)
      logger.level = ENV['ARMREST_LOG_LEVEL'] ? ENV['ARMREST_LOG_LEVEL'] : :info
      logger
    end

    extend self
  end
end
