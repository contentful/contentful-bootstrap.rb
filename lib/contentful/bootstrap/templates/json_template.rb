require 'json'
require 'contentful/bootstrap/templates/base'
require 'contentful/bootstrap/templates/links'

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

          check_version
        end

        def content_types
          json.fetch('contentTypes', [])
        end

        def assets
          @assets ||= process_assets
        end

        def entries
          @entries ||= process_entries
        end

        private

        def check_version
          json_version = json.fetch('version', 0)
          gem_major_version = Contentful::Bootstrap.major_version
          unless gem_major_version == json_version
            fail "JSON Templates Version Mismatch. Current Version: #{gem_major_version}"
          end
        end

        def json
          @json ||= ::JSON.parse(::File.read(@file))
        end

        def process_assets
          unprocessed_assets = json.fetch('assets', [])
          unprocessed_assets.map do |asset|
            asset['file'] = create_image(
              asset['file']['filename'],
              asset['file']['url']
            )
            asset
          end
        end

        def process_entries
          processed_entries = {}
          unprocessed_entries = json.fetch('entries', {})
          unprocessed_entries.each do |content_type_id, entry_list|
            entries_for_content_type = []
            entry_list.each do |entry|
              processed_entry = {}
              array_fields = []
              link_fields = []

              processed_entry['id'] = entry['sys']['id'] if entry.key?('sys') && entry['sys'].key?('id')

              entry.fetch('fields', {}).each do |field, value|
                link_fields << field if value.is_a? ::Hash
                array_fields << field if value.is_a? ::Array

                unless link_fields.include?(field) || array_fields.include?(field)
                  processed_entry[field] = value
                end
              end

              link_fields.each do |lf|
                processed_entry[lf] = create_link(entry['fields'][lf])
              end

              array_fields.each do |af|
                processed_entry[af] = entry['fields'][af].map do |item|
                  item.is_a?(::Hash) ? create_link(item) : item
                end
              end

              entries_for_content_type << processed_entry
            end

            processed_entries[content_type_id] = entries_for_content_type
          end

          processed_entries
        end

        def create_link(link_properties)
          link_type = link_properties['linkType'].capitalize
          id = link_properties['id']
          case link_type
          when 'Entry'
            Contentful::Bootstrap::Templates::Links::Entry.new(id)
          when 'Asset'
            Contentful::Bootstrap::Templates::Links::Asset.new(id)
          end
        end
      end
    end
  end
end
