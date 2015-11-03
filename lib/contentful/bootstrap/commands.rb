require "net/http"
require "contentful/management"
require "contentful/management/request"
require "contentful/management/error"
require "contentful/bootstrap/token"
require "contentful/bootstrap/server"
require "contentful/bootstrap/support"
require "contentful/bootstrap/templates"
require "contentful/bootstrap/version"

module Contentful
  module Bootstrap
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

        puts

        create_space(space_name, template_name)
      end

      def create_space(space_name, template_name = nil)
        management_client_init

        puts "Creating Space '#{space_name}'"
        space = nil
        begin
          space = Contentful::Management::Space.create(name: space_name)
        rescue Contentful::Management::NotFound
          puts "Your account has multiple organizations"
          print "Please insert the Organization ID you'd want to create the spaces for: "
          organization_id = gets.chomp
          space = Contentful::Management::Space.create(name: space_name, organization_id: organization_id)
        end

        puts "Space '#{space_name}' created!"
        puts

        unless template_name.nil?
          if templates.has_key? template_name.to_sym
            puts "Creating Template '#{template_name}'"

            templates[template_name.to_sym].new(space).run
            puts "Template '#{template_name}' created!"
          else
            puts "Template '#{template_name}' not found. Valid templates are '#{templates.keys.map(&:to_s).join('\', \'')}'"
          end
        end

        token = generate_token(space)
        puts
        puts "Space ID: '#{space.id}'"
        puts "Access Token: '#{token}'"
        puts
        puts "You can now insert those values into your configuration blocks"
      end

      def generate_token(space, token_name = "Bootstrap Token")
        management_client_init

        if space.is_a?(String)
          space = Contentful::Management::Space.find(space)
        end

        puts
        puts "Creating Delivery API Token"

        response = Contentful::Management::Request.new(
          "/#{space.id}/api_keys",
          'name' => token_name,
          'description' => "Created with 'contentful_bootstrap.rb v#{Contentful::Bootstrap::VERSION}'"
        ).post
        fail response if response.object.is_a?(Contentful::Management::Error)
        token = response.object["accessToken"]

        puts "Token '#{token_name}' created! - '#{token}'"

        token
      end

      private
      def management_client_init
        Contentful::Management::Client.new(Token.read, raise_errors: true)
      end

      def get_token
        silence_stderr do # Don't show any WEBrick related stuff
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
end
