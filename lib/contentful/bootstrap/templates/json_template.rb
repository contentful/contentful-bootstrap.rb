require 'json'
require 'contentful/bootstrap/templates/base'
require 'contentful/bootstrap/templates/links'

module Contentful
  module Bootstrap
    module Templates
      class JsonTemplate < Base
        CONTENT_TYPES_KEY = 'contentTypes'
        ENTRIES_KEY = 'entries'
        ASSETS_KEY = 'assets'
        BOOTSTRAP_PROCCESSED_KEY = 'bootstrapProcessed'
        DISPLAY_FIELD_KEY = 'displayField'
        ALTERNATE_DISPLAY_FIELD_KEY = 'display_field'
        SYS_KEY = 'sys'

        attr_reader :assets, :entries, :content_types

        def initialize(space, file, mark_processed = false, all = true)
          @space = space
          @file = file
          @all = all
          @mark_processed = mark_processed

          json

          @assets = process_assets
          @entries = process_entries
          @content_types = process_content_types

          check_version
        end

        def after_run
          return unless mark_processed?

          @json.fetch(CONTENT_TYPES_KEY, []).each do |content_type|
            content_type[BOOTSTRAP_PROCCESSED_KEY] = true
          end

          @json.fetch(ASSETS_KEY, []).each do |asset|
            asset[BOOTSTRAP_PROCCESSED_KEY] = true
          end

          @json.fetch(ENTRIES_KEY, {}).each do |_content_type_name, entry_list|
            entry_list.each do |entry|
              if entry.key?(SYS_KEY)
                entry[SYS_KEY][BOOTSTRAP_PROCCESSED_KEY] = true
              else
                entry[SYS_KEY] = { BOOTSTRAP_PROCCESSED_KEY => true }
              end
            end
          end

          ::File.write(@file, JSON.pretty_generate(@json))
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
        rescue
          puts 'File is not JSON. Exiting!'
          exit(1)
        end

        def process_content_types
          processed_content_types = json.fetch(CONTENT_TYPES_KEY, [])

          unless all?
            processed_content_types = processed_content_types.select do |content_type|
              !content_type.fetch(BOOTSTRAP_PROCCESSED_KEY, false)
            end
          end

          processed_content_types.each do |content_type|
            content_type[DISPLAY_FIELD_KEY] = content_type.key?(ALTERNATE_DISPLAY_FIELD_KEY) ? content_type.delete(ALTERNATE_DISPLAY_FIELD_KEY) : content_type[DISPLAY_FIELD_KEY]
          end

          processed_content_types
        end

        def process_assets
          unprocessed_assets = json.fetch(ASSETS_KEY, [])

          unless all?
            unprocessed_assets = unprocessed_assets.select do |asset|
              !asset.fetch(BOOTSTRAP_PROCCESSED_KEY, false)
            end
          end

          unprocessed_assets.map do |asset|
            asset['file'] = create_file(
              asset['file']['filename'],
              asset['file']['url'],
              { contentType: asset['file'].fetch('contentType', 'image/jpeg') }
            )
            asset
          end
        end

        def process_entries
          processed_entries = {}
          unprocessed_entries = json.fetch(ENTRIES_KEY, {})
          unprocessed_entries.each do |content_type_id, entry_list|
            entries_for_content_type = []

            unless all?
              entry_list = entry_list.select do |entry|
                !entry[SYS_KEY].fetch(BOOTSTRAP_PROCCESSED_KEY, false)
              end
            end

            entry_list.each do |entry|
              processed_entry = {}
              array_fields = []
              link_fields = []

              processed_entry['id'] = entry[SYS_KEY]['id'] if entry.key?(SYS_KEY) && entry[SYS_KEY].key?('id')

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

        def all?
          @all
        end

        def mark_processed?
          @mark_processed
        end
      end
    end
  end
end
