require 'contentful/management'
require 'contentful/management/error'
require 'contentful/bootstrap/templates'
require 'contentful/bootstrap/commands/base'
require 'contentful/bootstrap/commands/generate_token'

module Contentful
  module Bootstrap
    module Commands
      class CreateSpace < Base
        attr_reader :template_name, :json_template
        def initialize(token, space_name, template_name = nil, json_template = nil, trigger_oauth = true)
          super(token, space_name, trigger_oauth)
          @template_name = template_name
          @json_template = json_template
        end

        def run
          puts "Creating Space '#{@space}'"

          new_space = fetch_space

          puts "Space '#{@space}' created!"
          puts

          create_template(new_space) unless @template_name.nil?
          create_json_template(new_space) unless @json_template.nil?

          access_token = generate_token(new_space)
          puts
          puts "Space ID: '#{new_space.id}'"
          puts "Access Token: '#{access_token}'"
          puts
          puts 'You can now insert those values into your configuration blocks'
          puts "Manage your content at https://app.contentful.com/spaces/#{new_space.id}"

          new_space
        end

        protected

        def fetch_space
          new_space = nil
          begin
            new_space = Contentful::Management::Space.create(name: @space)
          rescue Contentful::Management::NotFound
            puts 'Your account has multiple organizations:'
            puts organizations.join('\n')
            print 'Please insert the Organization ID you\'d want to create the spaces for: '
            organization_id = gets.chomp
            new_space = Contentful::Management::Space.create(
              name: @space,
              organization_id: organization_id
            )
          end

          new_space
        end

        private

        def organizations
          client = management_client_init
          url = client.base_url.sub('spaces', 'token')
          response = Contentful::Management::Client.get_http(url, nil, client.request_headers)
          organization_ids = JSON.load(response.body.to_s)['includes']['Organization'].map do |org|
            "#{org['name']} - #{org['sys']['id']}"
          end
          organization_ids.sort
        end

        def templates
          {
            blog: Templates::Blog,
            gallery: Templates::Gallery,
            catalogue: Templates::Catalogue
          }
        end

        def create_template(space)
          if templates.key? @template_name.to_sym
            puts "Creating Template '#{@template_name}'"

            templates[@template_name.to_sym].new(space).run
            puts "Template '#{@template_name}' created!"
          else
            puts "Template '#{@template_name}' not found. Valid templates are '#{templates.keys.map(&:to_s).join('\', \'')}'"
          end
          puts
        end

        def create_json_template(space)
          if File.exist?(@json_template)
            puts "Creating JSON Template '#{@json_template}'"
            Templates::JsonTemplate.new(space, @json_template).run
            puts "JSON Template '#{@json_template}' created!"
          else
            puts "JSON Template '#{@json_template}' does not exist. Please check that you specified the correct file name."
          end
          puts
        end

        def generate_token(space)
          Contentful::Bootstrap::Commands::GenerateToken.new(
            @token, space, 'Bootstrap Token', false
          ).run
        end
      end
    end
  end
end
