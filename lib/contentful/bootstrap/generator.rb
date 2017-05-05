require 'contentful'
require 'inifile'
require 'json'
require 'zlib'
require 'contentful/bootstrap/version'

module Contentful
  module Bootstrap
    class Generator
      attr_reader :content_types_only

      def initialize(space_id, access_token, content_types_only)
        @client = Contentful::Client.new(access_token: access_token, space: space_id)
        @content_types_only = content_types_only
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

      def assets
        return [] if content_types_only

        proccessed_assets = @client.assets(limit: 1000).map do |asset|
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
          result['displayField'] = type.display_field unless type.display_field.nil?

          result['fields'] = type.fields.map do |field|
            map_field_properties(field)
          end

          result
        end
        proccessed_content_types.sort_by { |item| item['id'] }
      end

      def entries
        return {} if content_types_only

        entries = {}

        @client.entries(limit: 1000).each do |entry|
          result = { 'sys' => { 'id' => entry.sys[:id] }, 'fields' => {} }

          entry.fields.each do |key, value|
            value = map_field(value)
            result['fields'][field_id(entry, key)] = value unless value.nil?
          end

          ct_id = entry.content_type.sys[:id]
          entries[ct_id] = [] if entries[ct_id].nil?
          entries[ct_id] << result
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

        [:id, :name, :type, :link_type, :required, :localized].each do |property|
          value = field.public_send(property) if field.respond_to?(property)
          properties[Support.camel_case(property.to_s).to_sym] = value unless value.nil? || [:required, :localized].include?(property)
        end

        items = field.items if field.respond_to?(:items)
        properties[:items] = map_field_properties(items) unless items.nil?

        properties
      end
    end
  end
end
