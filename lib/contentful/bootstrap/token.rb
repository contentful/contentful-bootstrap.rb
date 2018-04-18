require 'inifile'

module Contentful
  module Bootstrap
    class Token
      CONFIG_ENV = 'CONTENTFUL_ENV'.freeze
      DEFAULT_SECTION = 'global'.freeze
      DEFAULT_PATH = '.contentfulrc'.freeze
      MANAGEMENT_TOKEN = 'CONTENTFUL_MANAGEMENT_ACCESS_TOKEN'.freeze
      DELIVERY_TOKEN = 'CONTENTFUL_DELIVERY_ACCESS_TOKEN'.freeze
      ORGANIZATION_ID = 'CONTENTFUL_ORGANIZATION_ID'.freeze
      SPACE_ID = 'SPACE_ID'.freeze

      attr_reader :config_path

      def initialize(config_path = '')
        @config_path = config_path
      end

      def ==(other)
        return false unless other.is_a?(Contentful::Bootstrap::Token)
        other.config_path == @config_path
      end

      def present?
        return false unless ::File.exist? filename
        config_file[config_section].key? MANAGEMENT_TOKEN
      end

      def read
        config_file[config_section].fetch(MANAGEMENT_TOKEN)
      rescue KeyError
        raise 'Token not found'
      end

      def read_organization_id
        config_file[config_section].fetch(ORGANIZATION_ID, nil)
      end

      def write(value, section = nil, key = MANAGEMENT_TOKEN)
        file = config_file
        file[section || config_section][key] = value
        file.save
      end

      def write_organization_id(organization_id)
        write(organization_id, nil, ORGANIZATION_ID)
      end

      def write_access_token(space_name, token)
        write(token, space_name, DELIVERY_TOKEN)
      end

      def write_space_id(space_name, space_id)
        write(space_id, space_name, SPACE_ID)
      end

      def filename
        return config_path unless config_path.empty?
        ::File.join(ENV['HOME'], DEFAULT_PATH)
      end

      def config_section
        return ENV[CONFIG_ENV] if config_file.has_section? ENV[CONFIG_ENV]
        DEFAULT_SECTION
      end

      def config_file
        @config_file ||= ::File.exist?(filename) ? IniFile.load(filename) : IniFile.new(filename: filename)
      end
    end
  end
end
