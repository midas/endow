module Endow
  module ErrorHandling

  protected

    def retryable_errors
      graceful_errors
    end

    def graceful_error_for( error )
      if ( graceful_error = graceful_errors_map[error])
        return graceful_error
      end

      graceful_errors_map.each do |klass, graceful_error|
        return graceful_error if error.kind_of?( klass )
      end

      raise "Unexpected problem while attempting graceful handling of error: #{error.class.name} #{error.message}"
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
      graceful_error = graceful_error_for( e )
      msg = "#{self.class.name}: #{graceful_error[:msg]}"
      log_graceful_error( msg )
      raise graceful_error[:klass], msg, e.backtrace
    end

  end
end
