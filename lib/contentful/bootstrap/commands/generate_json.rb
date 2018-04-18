require 'contentful/bootstrap/generator'
require 'contentful/bootstrap/commands/base'

module Contentful
  module Bootstrap
    module Commands
      class GenerateJson
        attr_reader :space_id, :filename, :access_token, :content_types_only, :use_preview, :content_type_ids, :environment
        def initialize(
            space_id,
            access_token,
            environment = 'master',
            filename = nil,
            content_types_only = false,
            quiet = false,
            use_preview = false,
            content_type_ids = []
        )
          @space_id = space_id
          @access_token = access_token
          @environment = environment
          @filename = filename
          @content_types_only = content_types_only
          @quiet = quiet
          @use_preview = use_preview
          @content_type_ids = content_type_ids
        end

        def run
          if access_token.nil?
            output 'Access Token not specified'
            output 'Exiting!'
            exit(1)
          end

          output "Generating JSON Template for Space: '#{space_id}'"
          output

          json = Contentful::Bootstrap::Generator.new(
            space_id,
            access_token,
            environment,
            content_types_only,
            use_preview,
            content_type_ids
          ).generate_json

          write(json)
        end

        def write(json)
          if filename.nil?
            output "#{json}\n"
          else
            output "Saving JSON template to '#{filename}'"
            ::File.write(filename, json)
          end
        end

        protected

        def output(text = nil)
          Support.output(text, @quiet)
        end
      end
    end
  end
end
