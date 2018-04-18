require 'net/http'
require 'contentful/management'
require 'contentful/bootstrap/server'
require 'contentful/bootstrap/support'

module Contentful
  module Bootstrap
    module Commands
      class Base
        attr_reader :space, :token, :options, :quiet, :no_input

        def initialize(token, space, options = {})
          trigger_oauth = options.fetch(:trigger_oauth, true)

          @token = token
          @options = options
          @quiet = options.fetch(:quiet, false)
          @no_input = options.fetch(:no_input, false)

          configuration if trigger_oauth
          client if trigger_oauth
          @space = space
        end

        def run
          raise 'must implement'
        end

        def client
          @client ||= ::Contentful::Management::Client.new(
            @token.read,
            default_locale: options.fetch(:locale, 'en-US'),
            raise_errors: true,
            application_name: 'bootstrap',
            application_version: ::Contentful::Bootstrap::VERSION
          )
        end

        protected

        def output(text = nil)
          Support.output(text, @quiet)
        end

        private

        def configuration
          if @token.present?
            output 'OAuth token found, moving on!'
            return
          end

          Support.input('OAuth Token not found, do you want to create a new configuration file? (Y/n): ', no_input) do |answer|
            if answer.casecmp('n').zero?
              output 'Exiting!'
              exit
            end
          end

          raise 'OAuth token required to proceed' if no_input

          output "Configuration will be saved on #{@token.filename}"
          output 'A new tab on your browser will open for requesting OAuth permissions'
          token_server
          output
        end

        def token_server
          Support.silence_stderr do # Don't show any WEBrick related stuff
            server = Contentful::Bootstrap::Server.new(@token)

            server.start

            sleep(1) until server.running? # Wait for Server Init

            Net::HTTP.get(URI('http://localhost:5123'))

            sleep(1) until @token.present? # Wait for User to do OAuth cycle

            server.stop
          end
        end
      end
    end
  end
end
