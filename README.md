# Endow

A library to assist in consuming API endpoints.


## Installation

Add this line to your application's Gemfile:

    gem 'endow'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install endow


## Usage

### Setting URI Content (URI Parameters)

Restful URIs sometimes use templated URI parameters, a la Rails, ie. `/people/:id` or `people/:person_id/things`.  To set the content of 
the URI parmeters use the `#set_uri_content` method.  You must implement the `#endpoint_template` method as opposed to the `endpoint` method
when using URI parameters.

    class SomeEndpoint < Endow::Endpoint
      def initialize( attributes )
        @attributes = attributes

        set_uri_content( attributes.slice( :person_id ))
        set_content( attributes.slice( :thing ))
      end

      def endpoint_template
        'people/:person_id/things'
      end

      def http_verb
        :post
      end
    end
