require "json"
require "contentful/bootstrap/templates/base"
require "contentful/bootstrap/templates/links"

module Contentful
  module Bootstrap
    module Templates
      class JsonTemplate < Base
        def initialize(space, file)
          @space = space
          @file = file
          @assets = nil
          @entries = nil
          json
        end

        def content_types
          json.fetch("content_types", [])
        end

        def assets
          @assets ||= process_assets
        end

        def entries
          @entries ||= process_entries
        end

        private
        def json
          @json ||= JSON.parse(File.read(@file))
        end

        def process_assets
          unprocessed_assets = json.fetch("assets", [])
          unprocessed_assets.map do |asset|
            asset["file"] = create_image(
              asset["file"]["filename"],
              asset["file"]["url"]
            )
            asset
          end
        end

        def process_entries
          processed_entries = {}
          unprocessed_entries = json.fetch("entries", {})
          unprocessed_entries.each do |content_type_id, entry_list|
            entries_for_content_type = []
            entry_list.each do |entry|
              link_fields = []
              entry.each do |field, value|
                link_fields << field if value.is_a? Hash
              end

              link_fields.each do |lf|
                entry[lf] = create_link(entry[lf])
              end

              entries_for_content_type << entry
            end

            processed_entries[content_type_id] = entries_for_content_type
          end

          processed_entries
        end

        def create_link(link_properties)
          link_type = link_properties["link_type"].capitalize
          id = link_properties["id"]
          Object.const_get("Contentful::Bootstrap::Templates::Links::#{link_type}").new(id)
        end
      end
    end
  end
end
