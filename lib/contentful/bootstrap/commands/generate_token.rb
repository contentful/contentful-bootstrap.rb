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
        def initialize(token, space, options = {})
          @token_name = options.fetch(:token_name, 'Bootstrap Token')

          super(token, space, options)
        end

        def run
          output 'Creating Delivery API Token'

          fetch_space

          access_token = fetch_access_token

          output "Token '#{token_name}' created! - '#{access_token}'"
          Support.input('Do you want to write the Delivery Token to your configuration file? (Y/n): ', no_input) do |answer|
            unless answer.casecmp('n').zero?
              @token.write_access_token(@actual_space.name, access_token)
              @token.write_space_id(@actual_space.name, @actual_space.id)
            end
          end

          access_token
        end

        def fetch_space
          @actual_space = if @space.is_a?(String)
                            client.spaces.find(@space)
                          else
                            @space
                          end
        end

        def fetch_access_token
          @actual_space.api_keys.create(
            name: token_name,
            description: "Created with 'contentful_bootstrap.rb v#{Contentful::Bootstrap::VERSION}'"
          ).access_token
        end
      end
    end
  end
end
