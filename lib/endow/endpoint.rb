module Endow
  module Endpoint

    extend ActiveSupport::Concern

    included do
      include Retryable
      include ErrorHandling
      include Logging
      include Wisper::Publisher
    end

    def initialize
      set_content nil
    end

    def call
      with_graceful_error_handling do
        attempt = 0
        retryable on: retryable_errors,
                  times: retryable_times,
                  sleep: retryable_sleep do
          attempt += 1
          log_connection( self, attempt )

          if success_error_codes.include?( response.code )
            handle_successful_response
          else
            _handle_unsuccessful_response
          end
        end
      end
    end

    def request_url
      request.url
    end

    def request_query
      request.query
    end

    def request_body
      request.body
    end

    def request_headers
      request.headers
    end

    def to_s
      "#<#{self.class.name}:#{object_id} " +
        "@verb=#{http_verb.inspect} " +
        "@url=#{request_url.to_s.inspect} " +
        "@query=#{request_query.inspect} " +
        "@body=#{request_body.inspect } " +
        "@headers=#{request_headers.inspect}>"
    end

  protected

    def response
      @response ||= HTTPI.request( http_verb, request )
    end

    def request
      @request ||= HTTPI::Request.new( request_params ).tap do |req|
        req.headers = default_headers
        req.auth.ssl.verify_mode = ssl_verify_mode
      end
    end

    def request_params
      {
        url: url,
        open_timeout: open_timeout_in_seconds,
        read_timeout: read_timeout_in_seconds
      }.reject { |k,v| v.blank? }
    end

    def handle_successful_response
      check_response_on_success( response )

      response_wrapper_class.new( decode_body( response.body )).tap do |response_body|
        publish :success,
                response_body,
                response
      end
    end

    def check_response_on_success( response )
      # purposefully empty
    end

    def response_wrapper_class
      raise NotImplementedError
    end

    def handle_unsuccessful_response
      publish :error, response
    end

    def _handle_unsuccessful_response
      custom_handler_method = "handle_unsuccessful_response_#{response.code}"

      unless respond_to?( custom_handler_method )
        handle_unsuccessful_response
        return
      end

      send( custom_handler_method )
    end

    def set_content( content )
      send "set_content_as_#{content_type_name}", content
    end

    def set_content_as_no_content_type_specified( content )
      if http_verb.to_sym == :get
        request.query = make_query_string( content )
      elsif http_verb.to_sym == :post
        request.body = make_query_string( content )
      end
    end

    def set_content_as_application_json( content )
      request.body = MultiJson.dump( content || {} )
    end

    def decode_body( content )
      send "decode_body_as_#{accept_name}", content
    end

    def decode_body_as_no_accept_specified( content )
      content
    end

    def decode_body_as_application_json( content )
      MultiJson.load( content )
    end

    def decode_body_as_application_xml( content )
      raise NotImplementedError
    end

    def content_type_name
      content_type.blank? ?
        :no_content_type_specified :
        content_type.split( '/' ).join( '_' )
    end

    def accept_name
      accept.blank? ?
        :no_accept_specified :
        accept.split( '/' ).join( '_' )
    end

    def default_headers
      {
        'Accept'       => accept,
        'Content-Type' => content_type,
      }.reject { |k,v| v.blank? }
    end

    def make_query_string( content )
      content.merge( base_content ).to_query
    end

    def base_content
      {}
    end

    def url
      File.join( base_url, endpoint )
    end

    def http_verb
      :get
    end

    def success_error_codes
      [200]
    end

    def open_timeout_in_seconds
      15
    end

    def read_timeout_in_seconds
      15
    end

    def retryable_times
      1
    end

    def retryable_sleep
      false
    end

    def accept
      nil
    end

    def accept_version
      raise NotImplementedError
    end

    def content_type
      nil
    end

    def endpoint
      raise NotImplementedError
    end

    def authentication_token_key
      raise NotImplementedError
    end

    def ssl_verify_mode
      raise NotImplementedError
    end

    def ensure_date( time_or_string )
      return nil if time_or_string.blank?
      if time_or_string.is_a?( String )
        begin
          return Date.strptime( time_or_string, Date::DATE_FORMATS[:api_internal] )
        rescue ArgumentError
          return Date.strptime( time_or_string, Date::DATE_FORMATS[:isdn] )
        end
      end
      time_or_string.to_date
    end

  end
end