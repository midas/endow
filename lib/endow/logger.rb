module Endow
  class Logger

    def self.log_connection( service, attempt, attempts=nil )
      log "#{green_prefix} #{service.class.name} (#{attempts_segment attempt, attempts}) #{service_options service}"
    end

    def self.log_graceful_error( msg )
      log "#{red_prefix} #{msg}"
    end

    def self.log( msg )
      return unless logger
      #TODO make this more adaptable
      logger.info( msg )
    end

    def self.logger
      Endow.configuration.logger
    end

    def self.green_prefix
      #TODO change to another ANSI library
      "#{indention}[#{ANSI.green { label }}]"
    end

    def self.red_prefix
      #TODO change to another ANSI library
      "#{indention}[#{ANSI.red { error_label }}]"
    end

    def self.service_options( service )
      service.respond_to?( :options_for_log ) ?
        "with #{service.options_for_log.inspect}" :
        nil
    end

    def self.attempts_segment( attempt, attempts )
      attempts.blank? ?
        "Attempt #{attempt}" :
        "Attempt #{attempt} of #{attempts}"
    end

    def self.label
      "Service Connection"
    end

    def self.error_label
      "Service ERROR"
    end

    def self.indention
      "  "
    end

  end
end
