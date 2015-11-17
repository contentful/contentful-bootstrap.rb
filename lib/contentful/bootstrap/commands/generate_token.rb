require 'contentful/management'
require 'contentful/management/error'
require 'contentful/management/request'
require 'contentful/bootstrap/version'
require 'contentful/bootstrap/commands/base'

module Contentful
  module Bootstrap
    module Commands
      class GenerateToken < Base
        attr_reader :token_name
        def initialize(token, space, token_name = 'Bootstrap Token', trigger_oauth = true)
          super(token, space, trigger_oauth)
          @token_name = token_name
          @actual_space = space unless space.is_a?(String)
        end

        def run
          puts 'Creating Delivery API Token'

          fetch_space

          access_token = fetch_access_token

          puts "Token '#{token_name}' created! - '#{access_token}'"
          print 'Do you want to write the Delivery Token to your configuration file? (Y/n): '
          unless gets.chomp.downcase == 'n'
            @token.write_access_token(@actual_space.name, access_token)
            @token.write_space_id(@actual_space.name, @actual_space.id)
          end

          access_token
        end

        def fetch_space
          @actual_space ||= Contentful::Management::Space.find(@space)
        end

        def fetch_access_token
          response = Contentful::Management::Request.new(
            "/#{@actual_space.id}/api_keys",
            'name' => token_name,
            'description' => "Created with 'contentful_bootstrap.rb v#{Contentful::Bootstrap::VERSION}'"
          ).post
          fail response if response.object.is_a?(Contentful::Management::Error)

          response.object['accessToken']
        end
      end
    end
  end
end
