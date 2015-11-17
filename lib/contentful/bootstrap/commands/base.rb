require 'net/http'
require 'contentful/management'
require 'contentful/bootstrap/server'
require 'contentful/bootstrap/support'

module Contentful
  module Bootstrap
    module Commands
      class Base
        include Support
        attr_reader :space, :token

        def initialize(token, space, trigger_oauth = true)
          @token = token
          configuration if trigger_oauth
          management_client_init if trigger_oauth
          @space = space
        end

        def run
          fail 'must implement'
        end

        private

        def management_client_init
          Contentful::Management::Client.new(@token.read, raise_errors: true)
        end

        def configuration
          if @token.present?
            puts 'OAuth token found, moving on!'
            return
          end

          print 'OAuth Token not found, do you want to create a new configuration file? (Y/n): '
          if gets.chomp.downcase == 'n'
            puts 'Exiting!'
            exit
          end

          puts "Configuration will be saved on #{@token.filename}"
          puts 'A new tab on your browser will open for requesting OAuth permissions'
          token_server
          puts
        end

        def token_server
          silence_stderr do # Don't show any WEBrick related stuff
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
