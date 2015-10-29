require "net/http"
require "contentful/management"
require "contentful_bootstrap/token"
require "contentful_bootstrap/server"
require "contentful_bootstrap/support"
require "contentful_bootstrap/templates"

module ContentfulBootstrap
  class Commands
    include Support

    def init(space_name, template_name = nil)
      if !Token.present?
        puts "A new tab on your browser will open for requesting OAuth permissions"
        get_token
        puts "OAuth permissions successfully saved, your OAuth token is present in '.contentful_token'"
      else
        puts "OAuth token found, moving on!"
      end

      create_space(space_name, template_name)
    end

    def create_space(space_name, template_name = nil)
      management_client_init

      puts "Creating Space '#{space_name}'"
      space = Contentful::Management::Space.create(name: space_name)
      puts "Space '#{space_name}' created!"

      return if template_name.nil?

      if templates.has_key? template_name.to_sym
        puts "Creating Template '#{template_name}'"

        templates[template_name.to_sym].new(space).run
        puts "Template '#{template_name}' created!"
      else
        puts "Template '#{template_name}' not found. Valid templates are '#{templates.keys.map(&:to_s).join('\', \'')}'"
      end
    end

    private
    def management_client_init
      Contentful::Management::Client.new(Token.read, raise_errors: true)
    end

    def get_token
      silence_stderr do # Don't show any Sinatra related stuff
        server = Server.new

        server.start

        while !server.running? # Wait for Server Init
          sleep(1)
        end

        Net::HTTP.get(URI('http://localhost:5123'))

        while !Token.present? # Wait for User to do OAuth cycle
          sleep(1)
        end

        server.stop
      end
    end

    def templates
      {
        blog: Templates::Blog,
        gallery: Templates::Gallery,
        catalogue: Templates::Catalogue
      }
    end
  end
end
