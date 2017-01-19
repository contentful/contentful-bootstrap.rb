require 'contentful/management'
require 'contentful/management/error'
require 'contentful/bootstrap/templates'
require 'contentful/bootstrap/commands/base'

module Contentful
  module Bootstrap
    module Commands
      class UpdateSpace < Base
        attr_reader :json_template
        def initialize(token, space_id, options = {})
          @json_template = options.fetch(:json_template, nil)
          @mark_processed = options.fetch(:mark_processed, false)
          @skip_content_types = options.fetch(:skip_content_types, false)

          super(token, space_id, options)
        end

        def run
          if @json_template.nil?
            output 'JSON Template not found. Exiting!'
            exit(1)
          end

          output "Updating Space '#{@space}'"

          update_space = fetch_space

          update_json_template(update_space)

          output
          output "Successfully updated Space #{@space}"

          update_space
        end

        protected

        def fetch_space
          Contentful::Management::Space.find(@space)
        rescue Contentful::Management::NotFound
          output 'Space Not Found. Exiting!'
          exit(1)
        end

        private

        def update_json_template(space)
          if ::File.exist?(@json_template)
            output "Updating from JSON Template '#{@json_template}'"
            Templates::JsonTemplate.new(space, @json_template, @mark_processed, false, @skip_content_types).run
            output "JSON Template '#{@json_template}' updated!"
          else
            output "JSON Template '#{@json_template}' does not exist. Please check that you specified the correct file name."
            exit(1)
          end
        end
      end
    end
  end
end
