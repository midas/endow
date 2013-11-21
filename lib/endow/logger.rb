module Endow
  class Logger

    def self.log_connection( service, attempt )
      log "#{green_prefix} #{service.class.name} (Attempt #{attempt})"
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
