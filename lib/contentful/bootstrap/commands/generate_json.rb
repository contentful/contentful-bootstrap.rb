require 'contentful/bootstrap/generator'
require 'contentful/bootstrap/commands/base'

module Contentful
  module Bootstrap
    module Commands
      class GenerateJson
        attr_reader :space_id, :filename, :access_token
        def initialize(space_id, access_token, filename = nil)
          @space_id = space_id
          @access_token = access_token
          @filename = filename
        end

        def run
          if access_token.nil?
            puts 'Access Token not specified'
            puts 'Exiting!'
            exit
          end

          puts "Generating JSON Template '#{filename}' for Space: '#{space_id}'"

          json = Contentful::Bootstrap::Generator.new(space_id, access_token).generate_json

          puts
          write(json)
        end

        def write(json)
          if filename.nil?
            puts "#{json}\n"
          else
            puts "Saving JSON template to '#{filename}'"
            ::File.write(filename, json)
          end
        end
      end
    end
  end
end
