require 'contentful'
require 'inifile'
require 'json'
require 'zlib'

module Contentful
  module Bootstrap
    class Generator
      def initialize(space_id, access_token)
        @client = Contentful::Client.new(access_token: access_token, space: space_id)
      end

      def generate_json
        template = {}
        template['content_types'] = content_types
        template['assets'] = assets
        template['entries'] = entries
        JSON.pretty_generate(template)
      end

      private

      def assets
        proccessed_assets = @client.assets.map do |asset|
          result = { 'id' => asset.sys[:id], 'title' => asset.title }
          result['file'] = {
            'filename' => ::File.basename(asset.file.file_name, '.*'),
            'url' => "https:#{asset.file.url}"
          }
          result
        end
        proccessed_assets.sort_by { |item| item['id'] }
      end

      def content_types
        proccessed_content_types = @client.content_types.map do |type|
          result = { 'id' => type.sys[:id], 'name' => type.name }
          result['display_field'] = type.display_field unless type.display_field.nil?

          result['fields'] = type.fields.map do |field|
            map_field_properties(field.properties)
          end

          result
        end
        proccessed_content_types.sort_by { |item| item['id'] }
      end

      def entries
        entries = {}

        @client.entries.each do |entry|
          result = { 'id' => entry.sys[:id] }

          entry.fields.each do |key, value|
            value = map_field(value)
            result[key] = value unless value.nil?
          end

          ct_id = entry.content_type.sys[:id]
          entries[ct_id] = [] if entries[ct_id].nil?
          entries[ct_id] << result
        end

        entries
      end

      def map_field(value)
        return value.map { |v| map_field(v) } if value.is_a? ::Array

        if value.is_a?(Contentful::Asset) || value.is_a?(Contentful::Entry)
          return {
            'link_type' => value.class.name.split('::').last,
            'id' => value.sys[:id]
          }
        end

        return nil if value.is_a?(Contentful::Link)

        value
      end

      def map_field_properties(properties)
        properties['link_type'] = properties.delete(:linkType) unless properties[:linkType].nil?

        items = properties[:items]
        properties[:items] = map_field_properties(items.properties) unless items.nil?

        properties.delete_if { |k, v| v.nil? || [:required, :localized].include?(k) }
        properties
      end
    end
  end
end
