require 'json'
require 'contentful/management'
require 'contentful/bootstrap/templates/links/base'

module Contentful
  module Bootstrap
    module Templates
      class Base
        attr_reader :environment, :skip_content_types

        def initialize(space, environment_id = 'master', quiet = false, skip_content_types = false, no_publish = false)
          @environment = space.environments.find(environment_id)
          @quiet = quiet
          @skip_content_types = skip_content_types
          @no_publish = no_publish
        end

        def run
          create_content_types unless skip_content_types
          create_assets
          create_entries

          after_run
        rescue Contentful::Management::Error => e
          error = e.error
          output "Error at: #{error[:url]}"
          output "Message: #{error[:message]}"
          output "Details: #{error[:details]}"

          raise e
        end

        def content_types
          []
        end

        def entries
          {}
        end

        def assets
          []
        end

        def after_run; end

        protected

        def output(text = nil)
          Support.output(text, @quiet)
        end

        def create_file(name, url, properties = {})
          image = Contentful::Management::File.new
          image.properties[:contentType] = properties.fetch(:contentType, 'image/jpeg')
          image.properties[:fileName] = name.to_s
          image.properties[:upload] = url
          image
        end

        private

        def create_content_types
          content_types.each do |ct|
            begin
              output "Creating Content Type '#{ct['name']}'"

              fields = []
              ct['fields'].each do |f|
                field = Contentful::Management::Field.new
                field.id = f['id']
                field.name = f['name']
                field.type = f['type']
                field.link_type = f['linkType'] if link?(f)

                if array_field?(f)
                  array_field = Contentful::Management::Field.new
                  array_field.type = f['items']['type']
                  array_field.link_type = f['items']['linkType']
                  field.items = array_field
                end

                fields << field
              end

              content_type = environment.content_types.create(
                id: ct['id'],
                name: ct['name'],
                displayField: ct['displayField'],
                description: ct['description'],
                fields: fields
              )

              content_type.activate
            rescue Contentful::Management::Conflict
              output "ContentType '#{ct['id']}' already created! Skipping"
              next
            end
          end
        end

        def link?(field)
          field.key?('linkType')
        end

        def array_field?(field)
          field.key?('items')
        end

        def create_assets
          assets.each do |asset_json|
            begin
              output "Creating Asset '#{asset_json['title']}'"
              asset = environment.assets.create(
                id: asset_json['id'],
                title: asset_json['title'],
                file: asset_json['file']
              )
              asset.process_file
            rescue Contentful::Management::Conflict
              output "Asset '#{asset_json['id']}' already created! Updating instead."

              asset = environment.assets.find(asset_json['id']).tap do |a|
                a.title = asset_json['title']
                a.file = asset_json['file']
              end

              asset.save
              asset.process_file
            end
          end

          assets.each do |asset_json|
            attempts = 0
            while attempts < 10
              asset = environment.assets.find(asset_json['id'])
              unless asset.file.url.nil?
                asset.publish unless @no_publish
                break
              end

              sleep(1) # Wait for Process
              attempts += 1
            end
          end
        end

        def create_entries
          content_types = []
          processed_entries = entries.map do |content_type_id, entry_list|
            content_type = environment.content_types.find(content_type_id)
            content_types << content_type

            entry_list.each.map do |e|
              array_fields = []
              regular_fields = []
              e.each do |field_name, value|
                if value.is_a? ::Array
                  array_fields << field_name
                  next
                end

                regular_fields << field_name
              end

              array_fields.each do |af|
                e[af].map! do |item|
                  if item.is_a? ::Contentful::Bootstrap::Templates::Links::Base
                    item.to_management_object
                  else
                    item
                  end
                end
                e[af.to_sym] = e.delete(af)
              end

              regular_fields.each do |rf|
                value = e.delete(rf)
                value = value.to_management_object if value.is_a? ::Contentful::Bootstrap::Templates::Links::Base
                e[rf.to_sym] = value
              end

              begin
                output "Creating Entry #{e[:id]}"
                entry = content_type.entries.create(id: e[:id])
                entry.save

                e = e.clone
                e[:id] = entry.id # in case no ID was specified in template
              rescue Contentful::Management::Conflict
                output "Entry '#{e[:id]}' already exists! Skipping"
              ensure
                next e
              end
            end
          end.flatten

          processed_entries = processed_entries.map do |e|
            output "Populating Entry #{e[:id]}"

            entry = environment.entries.find(e[:id])
            e.delete(:id)
            entry.update(e)
            entry.save

            10.times do
              break if environment.entries.find(entry.id).sys[:version] >= 4
              sleep(0.5)
            end

            entry.id
          end

          processed_entries.each do |e|
            output "Publishing Entry #{e}"
            environment.entries.find(e).publish
          end unless @no_publish
        end
      end
    end
  end
end
