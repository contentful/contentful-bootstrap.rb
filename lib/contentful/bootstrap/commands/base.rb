require 'net/http'
require 'contentful/bootstrap/server'
require 'contentful/bootstrap/support'
require 'contentful/bootstrap/management'

module Contentful
  module Bootstrap
    module Commands
      class Base
        attr_reader :space, :token, :options, :quiet

        def initialize(token, space, options = {})
          trigger_oauth = options.fetch(:trigger_oauth, true)

          @token = token
          @options = options
          @quiet = options.fetch(:quiet, false)

          configuration if trigger_oauth
          management_client_init if trigger_oauth
          @space = space
        end

        def run
          fail 'must implement'
        end

        protected

        def output(text = nil)
          Support.output(text, @quiet)
        end

        private

        def management_client_init
          ::Contentful::Bootstrap::Management.new(@token.read, raise_errors: true)
        end

        def configuration
          if @token.present?
            output 'OAuth token found, moving on!'
            return
          end

          print 'OAuth Token not found, do you want to create a new configuration file? (Y/n): '
          if gets.chomp.downcase == 'n'
            output 'Exiting!'
            exit
          end

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
