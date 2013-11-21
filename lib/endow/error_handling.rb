module Endow
  module ErrorHandling

  protected

    def retryable_errors
      graceful_errors
    end

    def graceful_errors
      graceful_errors_map.keys
    end

    def graceful_errors_map
      raise NotImplementedError
    end

    def with_graceful_error_handling( &block )
      block.call
    rescue *graceful_errors => e
      msg = "#{self.class.name}: #{graceful_errors_map[e.class][:msg]}"
      log_graceful_error( msg )
      raise graceful_errors_map[e.class][:klass],
            msg,
            e.backtrace
    end

  end
end
