require "logging"

module UfwUpdater
  module Log
    class << self
      def logger
        @logger ||= Logging.logger(STDOUT)
      end

      def logger=(logger)
        @logger = logger
      end
    end

    # Addition
    def self.included(base)
      class << base
        def logger
          Log.logger
        end
      end
    end

    def logger
      Log.logger
    end
  end
end
