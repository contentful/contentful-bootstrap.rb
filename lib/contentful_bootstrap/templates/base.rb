require "contentful/management"

module ContentfulBootstrap
  module Templates
    class Base
      attr_reader :space

      def initialize(space)
        @space = space
      end

      def run
        create_content_types
        create_assets
        create_entries
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

      protected
      def create_image(name, url)
        image = Contentful::Management::File.new
        image.properties[:contentType] = 'image/jpeg'
        image.properties[:fileName] = "#{name}.jpg"
        image.properties[:upload] = url
        image
      end

      private
      def create_content_types
        content_types.each do |ct|
          puts "Creating Content Type '#{ct[:name]}'"

          fields = []
          content_type = space.content_types.new
          content_type.id = ct[:id]
          content_type.name = ct[:name]
          content_type.display_field = ct[:display_field]

          ct[:fields].each do |f|
            field = Contentful::Management::Field.new
            field.id = f[:id]
            field.name = f[:name]
            field.type = f[:type]
            field.link_type = f[:link_type] if is_link?(f)

            if is_array?(f)
              array_field = Contentful::Management::Field.new
              array_field.type = f[:items][:type]
              array_field.link_type = f[:items][:link_type]
              field.items = array_field
            end

            fields << field
          end

          content_type.fields = fields
          content_type.save
          content_type.activate
        end
      end

      def is_link?(field)
        field.has_key?(:link_type)
      end

      def is_array?(field)
        field.has_key?(:items)
      end

      def create_assets
        assets.each do |asset|
          puts "Creating Asset '#{asset[:title]}'"
          asset = space.assets.create(asset)
          asset.process_file
          asset.publish
        end
      end

      def create_entries
        entries.each do |content_type_id, entry_list|
          content_type = space.content_types.find(content_type_id)
          entry_list.each_with_index do |e, index|
            puts "Creating Entry #{index} for #{content_type_id.capitalize}"

            array_fields = []
            e.each_pair do |field_name, value|
              array_fields << field_name if value.is_a? Array
            end

            array_fields.each do |af|
              e[af].map! do |f|
                space.send(f.kind).find(f.id)
              end
            end

            entry = content_type.entries.create(e)
            entry.save
            entry.publish
          end
        end
      end
    end
  end
end
