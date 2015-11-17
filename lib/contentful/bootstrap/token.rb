require "inifile"

module Contentful
  module Bootstrap
    class Token
      CONFIG_ENV = "CONTENTFUL_ENV".freeze
      DEFAULT_SECTION = "global".freeze
      DEFAULT_PATH = ".contentfulrc".freeze
      MANAGEMENT_TOKEN = "CONTENTFUL_MANAGEMENT_ACCESS_TOKEN".freeze
      DELIVERY_TOKEN = "CONTENTFUL_DELIVERY_ACCESS_TOKEN".freeze
      SPACE_ID = "SPACE_ID".freeze

      def self.set_path!(config_path = "")
        @@config_path = config_path
      end

      def self.present?
        return false unless ::File.exists? filename
        config_file[config_section].has_key? MANAGEMENT_TOKEN
      end

      def self.read
        begin
          config_file[config_section].fetch(MANAGEMENT_TOKEN)
        rescue KeyError
          fail "Token not found"
        end
      end

      def self.write(value, section = nil, key = MANAGEMENT_TOKEN)
        file = config_file
        file[section || config_section][key] = value
        file.save
      end

      def self.write_access_token(space_name, token)
        write(token, space_name, DELIVERY_TOKEN)
      end

      def self.write_space_id(space_name, space_id)
        write(space_id, space_name, SPACE_ID)
      end

      def self.filename
        return config_path if ::File.exist?(config_path)
        ::File.join(ENV['HOME'], DEFAULT_PATH)
      end

      def self.config_section
        return ENV[CONFIG_ENV] if config_file.has_section? ENV[CONFIG_ENV]
        DEFAULT_SECTION
      end

      def self.config_file
        ::File.exist?(filename) ? IniFile.load(filename) : IniFile.new(filename: filename)
      end

      def self.config_path
        @@config_path ||= ""
      end
    end
  end
end
