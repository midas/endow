require 'active_support'
require 'active_support/core_ext/string'
require "httpi"
require "multi_json"
require "retryable"
require "wisper"
require "endow/version"
require "ansi"

module Endow

  autoload :Configuration, 'endow/configuration'
  autoload :Endpoint,      'endow/endpoint'
  autoload :ErrorHandling, 'endow/error_handling'
  autoload :Logger,        'endow/logger'
  autoload :Logging,       'endow/logging'

  def self.configuration
    @configuration ||= Configuration.new
  end

  def self.configure
    yield( configuration ) if block_given?
  end

end
