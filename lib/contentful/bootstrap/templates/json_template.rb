require 'json'
require 'contentful/bootstrap/templates/base'
require 'contentful/bootstrap/templates/links'

module Contentful
  module Bootstrap
    module Templates
      class JsonTemplate < Base
        CONTENT_TYPES_KEY = 'contentTypes'.freeze
        ENTRIES_KEY = 'entries'.freeze
        ASSETS_KEY = 'assets'.freeze
        BOOTSTRAP_PROCCESSED_KEY = 'bootstrapProcessed'.freeze
        DISPLAY_FIELD_KEY = 'displayField'.freeze
        ALTERNATE_DISPLAY_FIELD_KEY = 'display_field'.freeze
        SYS_KEY = 'sys'.freeze

        attr_reader :assets, :entries, :content_types

        def initialize(space, file, environment = 'master', mark_processed = false, all = true, quiet = false, skip_content_types = false, no_publish = false)
          @file = file
          json
          check_version

          super(space, environment, quiet, skip_content_types, no_publish)

          @all = all
          @mark_processed = mark_processed

          @assets = process_assets
          @entries = process_entries
          @content_types = process_content_types
        end

        def after_run
          return unless mark_processed?

          # Re-parse JSON to avoid side effects from `Templates::Base`
          @json = parse_json

          json.fetch(CONTENT_TYPES_KEY, []).each do |content_type|
            content_type[BOOTSTRAP_PROCCESSED_KEY] = true
          end

          json.fetch(ASSETS_KEY, []).each do |asset|
            asset[BOOTSTRAP_PROCCESSED_KEY] = true
          end

          json.fetch(ENTRIES_KEY, {}).each do |_content_type_name, entry_list|
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

        def json
          @json ||= parse_json
        end

        private

        def parse_json
          ::JSON.parse(::File.read(@file))
        rescue StandardError
          output 'File is not JSON. Exiting!'
          exit(1)
        end

        def check_version
          json_version = json.fetch('version', 0)
          gem_major = Contentful::Bootstrap.major_version
          raise "JSON Templates Version Mismatch. Current Version: #{gem_major}" unless gem_major == json_version
        end

        def process_content_types
          processed_content_types = json.fetch(CONTENT_TYPES_KEY, [])

          unless all?
            processed_content_types = processed_content_types.reject do |content_type|
              content_type.fetch(BOOTSTRAP_PROCCESSED_KEY, false)
            end
          end

          processed_content_types.each do |content_type|
            content_type[DISPLAY_FIELD_KEY] = if content_type.key?(ALTERNATE_DISPLAY_FIELD_KEY)
                                                content_type.delete(ALTERNATE_DISPLAY_FIELD_KEY)
                                              else
                                                content_type[DISPLAY_FIELD_KEY]
                                              end
          end

          processed_content_types
        end

        def process_assets
          unprocessed_assets = json.fetch(ASSETS_KEY, [])

          unless all?
            unprocessed_assets = unprocessed_assets.reject do |asset|
              asset.fetch(BOOTSTRAP_PROCCESSED_KEY, false)
            end
          end

          unprocessed_assets.map do |asset|
            asset['file'] = create_file(
              asset['file']['filename'],
              asset['file']['url'],
              contentType: asset['file'].fetch('contentType', 'image/jpeg')
            )
            asset
          end
        end

        def process_entry(entry)
          processed_entry = {}
          processed_entry['id'] = entry[SYS_KEY]['id'] if entry.key?(SYS_KEY) && entry[SYS_KEY].key?('id')

          entry.fetch('fields', {}).each do |field, value|
            if link?(value)
              processed_entry[field] = create_link(value)
              next
            elsif array?(value)
              processed_entry[field] = value.map { |i| link?(i) ? create_link(i) : i }
              next
            end

            processed_entry[field] = value
          end

          processed_entry
        end

        def process_entries
          unprocessed_entries = json.fetch(ENTRIES_KEY, {})
          unprocessed_entries.each_with_object({}) do |(content_type_id, entry_list), processed_entries|
            entries_for_content_type = []

            unless all?
              entry_list = entry_list.reject do |entry|
                entry[SYS_KEY].fetch(BOOTSTRAP_PROCCESSED_KEY, false)
              end
            end

            entry_list.each do |entry|
              entries_for_content_type << process_entry(entry)
            end

            processed_entries[content_type_id] = entries_for_content_type
          end
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

        def link?(value)
          value.is_a?(::Hash) && value.key?('id') && value.key?('linkType')
        end

        def array?(value)
          value.is_a?(::Array)
        end
      end
    end
  end
end
