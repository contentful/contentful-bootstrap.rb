require 'contentful/bootstrap/generator'
require 'contentful/bootstrap/commands/base'

module Contentful
  module Bootstrap
    module Commands
      class GenerateJson
        attr_reader :space_id, :filename, :access_token, :content_types_only, :preview
        def initialize(space_id, access_token, filename = nil, content_types_only = false, quiet = false, preview: false)
          @space_id = space_id
          @access_token = access_token
          @filename = filename
          @content_types_only = content_types_only
          @quiet = quiet
          @preview = preview
        end

        def run
          if access_token.nil?
            puts 'Access Token not specified'
            puts 'Exiting!'
            exit
          end

          puts "Generating JSON Template '#{filename}' for Space: '#{space_id}'"

          json = Contentful::Bootstrap::Generator.new(space_id, access_token, content_types_only, preview: preview).generate_json

          puts
          write(json)
        end

        def write(json)
          if filename.nil?
            puts "#{json}\n"
          else
            puts "Saving JSON template to '#{filename}'" unless @quiet
            ::File.write(filename, json)
          end
        end
      end
    end
  end
end
