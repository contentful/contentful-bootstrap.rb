require 'contentful/management'
require 'contentful/management/error'
require 'contentful/bootstrap/templates'
require 'contentful/bootstrap/commands/base'

module Contentful
  module Bootstrap
    module Commands
      class UpdateSpace < Base
        attr_reader :json_template
        def initialize(token, space_id, json_template = nil, mark_processed = false, trigger_oauth = true)
          super(token, space_id, trigger_oauth)
          @json_template = json_template
          @mark_processed = mark_processed
        end

        def run
          if @json_template.nil?
            puts 'JSON Template not found. Exiting!'
            exit(1)
          end

          puts "Updating Space '#{@space}'"

          update_space = fetch_space

          update_json_template(update_space)

          puts
          puts "Successfully updated Space #{@space}"

          update_space
        end

        protected

        def fetch_space
          Contentful::Management::Space.find(@space)
        rescue Contentful::Management::NotFound
          puts 'Space Not Found. Exiting!'
          exit(1)
        end

        private

        def update_json_template(space)
          if ::File.exist?(@json_template)
            puts "Updating from JSON Template '#{@json_template}'"
            Templates::JsonTemplate.new(space, @json_template, @mark_processed, false).run
            puts "JSON Template '#{@json_template}' updated!"
          else
            puts "JSON Template '#{@json_template}' does not exist. Please check that you specified the correct file name."
            exit(1)
          end
        end
      end
    end
  end
end
