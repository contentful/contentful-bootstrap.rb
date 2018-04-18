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
        Contentful::Bootstrap::Commands::CreateSpace.new(
          @token, space_name, options
        ).run
      end

      def update_space(space_id, options = {})
        Contentful::Bootstrap::Commands::UpdateSpace.new(
          @token, space_id, options
        ).run
      end

      def generate_token(space, options = {})
        Contentful::Bootstrap::Commands::GenerateToken.new(
          @token, space, options
        ).run
      end

      def generate_json(space_id, options = {})
        filename = options.fetch(:filename, nil)
        access_token = options.fetch(:access_token, nil)
        environment = options.fetch(:environment, 'master')
        content_types_only = options.fetch(:content_types_only, false)
        quiet = options.fetch(:quiet, false)
        use_preview = options.fetch(:use_preview, false)
        content_type_ids = options.fetch(:content_type_ids, [])

        raise 'Access Token required' if access_token.nil?

        Contentful::Bootstrap::Commands::GenerateJson.new(
          space_id,
          access_token,
          environment,
          filename,
          content_types_only,
          quiet,
          use_preview,
          content_type_ids
        ).run
      end
    end
  end
end
