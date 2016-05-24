require 'contentful/bootstrap/token'
require 'contentful/bootstrap/commands'

module Contentful
  module Bootstrap
    class CommandRunner
      attr_reader :config_path, :token

      def initialize(config_path = '')
        @config_path = config_path
        @token = Token.new(config_path)
      end

      def create_space(space_name, options = {})
        template_name = options.fetch(:template, nil)
        json_template = options.fetch(:json_template, nil)
        mark_processed = options.fetch(:mark_processed, false)
        trigger_oauth = options.fetch(:trigger_oauth, true)

        Contentful::Bootstrap::Commands::CreateSpace.new(
          @token, space_name, template_name, json_template, mark_processed, trigger_oauth
        ).run
      end

      def update_space(space_id, options = {})
        json_template = options.fetch(:json_template, nil)
        mark_processed = options.fetch(:mark_processed, false)
        trigger_oauth = options.fetch(:trigger_oauth, true)

        Contentful::Bootstrap::Commands::UpdateSpace.new(
          @token, space_id, json_template, mark_processed, trigger_oauth
        ).run
      end

      def generate_token(space, options = {})
        token_name = options.fetch(:name, 'Bootstrap Token')
        trigger_oauth = options.fetch(:trigger_oauth, true)

        Contentful::Bootstrap::Commands::GenerateToken.new(
          @token, space, token_name, trigger_oauth
        ).run
      end

      def generate_json(space_id, options = {})
        filename = options.fetch(:filename, nil)
        access_token = options.fetch(:access_token, nil)

        fail 'Access Token required' if access_token.nil?

        Contentful::Bootstrap::Commands::GenerateJson.new(
          space_id, access_token, filename
        ).run
      end
    end
  end
end
