module Endow
  module Logging

    def log_connection( service, attempt )
      Endow::Logger.log_connection( service, attempt )
    end

    def log_graceful_error( msg )
      Endow::Logger.log_graceful_error( msg )
    end

  end
end
