require 'contentful'
require 'inifile'
require 'json'
require 'zlib'
require 'contentful/bootstrap/version'

module Contentful
  module Bootstrap
    class Generator
      DELIVERY_API_URL = 'cdn.contentful.com'.freeze
      PREVIEW_API_URL = 'preview.contentful.com'.freeze

      attr_reader :content_types_only, :content_type_ids, :client

      def initialize(space_id, access_token, environment, content_types_only, use_preview, content_type_ids)
        @client = Contentful::Client.new(
          space: space_id,
          access_token: access_token,
          environment: environment,
          application_name: 'bootstrap',
          application_version: ::Contentful::Bootstrap::VERSION,
          api_url: use_preview ? PREVIEW_API_URL : DELIVERY_API_URL
        )
        @content_types_only = content_types_only
        @content_type_ids = content_type_ids
      end

      def generate_json
        template = {}
        template['version'] = Contentful::Bootstrap.major_version
        template['contentTypes'] = content_types
        template['assets'] = assets
        template['entries'] = entries
        JSON.pretty_generate(template)
      end

      private

      def content_types
        query = {}
        query['sys.id[in]'] = content_type_ids.join(',') unless content_type_ids.empty?

        proccessed_content_types = @client.content_types(query).map do |type|
          result = { 'id' => type.sys[:id], 'name' => type.name }
          result['displayField'] = type.display_field unless type.display_field.nil?

          result['fields'] = type.fields.map do |field|
            map_field_properties(field)
          end

          result
        end
        proccessed_content_types.sort_by { |item| item['id'] }
      end

      def assets
        return [] if content_types_only

        processed_assets = []

        query = { order: 'sys.createdAt', limit: 1000 }
        assets_count = @client.assets(limit: 1).total
        ((assets_count / 1000) + 1).times do |i|
          query[:skip] = i * 1000

          @client.assets(query).each do |asset|
            processed_asset = {
              'id' => asset.sys[:id],
              'title' => asset.title,
              'file' => {
                'filename' => ::File.basename(asset.file.file_name, '.*'),
                'url' => "https:#{asset.file.url}"
              }
            }
            processed_assets << processed_asset
          end
        end

        processed_assets.sort_by { |item| item['id'] }
      end

      def entries
        return {} if content_types_only

        entries = {}

        query = { order: 'sys.createdAt', limit: 1000 }
        count_query = { limit: 1 }

        unless content_type_ids.empty?
          search_key = 'sys.contentType.sys.id[in]'
          ids = content_type_ids.join(',')

          query[search_key] = ids
          count_query[search_key] = ids
        end

        entries_count = @client.entries(count_query).total
        ((entries_count / 1000) + 1).times do |i|
          query[:skip] = i * 1000

          @client.entries(query).each do |entry|
            result = { 'sys' => { 'id' => entry.sys[:id] }, 'fields' => {} }

            entry.fields.each do |key, value|
              value = map_field(value)
              result['fields'][field_id(entry, key)] = value unless value.nil?
            end

            ct_id = entry.content_type.sys[:id]
            entries[ct_id] = [] if entries[ct_id].nil?
            entries[ct_id] << result
          end
        end

        entries
      end

      def field_id(entry, field_name)
        entry.raw['fields'].keys.detect { |f| f == field_name.to_s || f == Support.camel_case(field_name.to_s).to_s }
      end

      def map_field(value)
        return value.map { |v| map_field(v) } if value.is_a? ::Array

        if value.is_a?(Contentful::Asset) || value.is_a?(Contentful::Entry)
          return {
            'linkType' => value.class.name.split('::').last,
            'id' => value.sys[:id]
          }
        end

        return nil if value.is_a?(Contentful::Link)

        value
      end

      def map_field_properties(field)
        properties = {}

        %i[id name type link_type required localized].each do |property|
          value = field.public_send(property) if field.respond_to?(property)
          properties[Support.camel_case(property.to_s).to_sym] = value unless value.nil? || %i[required localized].include?(property)
        end

        items = field.items if field.respond_to?(:items)
        properties[:items] = map_field_properties(items) unless items.nil?

        properties
      end
    end
  end
end
