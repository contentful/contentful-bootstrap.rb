require "contentful/management"

module ContentfulBootstrap
  module Templates
    class Base
      attr_reader :space

      def initialize(space)
        @space = space
      end

      def run
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
            field.link_type = f[:link_type] if f.has_key?(:link_type)
            fields << field
          end

          content_type.fields = fields
          content_type.save
          content_type.activate
        end

        entries.each do |content_type_id, entry_list|
          content_type = space.content_types.find(content_type_id)
          entry_list.each_with_index do |e, index|
            puts "Creating Entry #{index} for #{content_type_id.capitalize}"
            entry = content_type.entries.create(e)
            entry.save
            entry.publish
          end
        end
      end

      def content_types
        raise "must implement"
      end

      def entries
        raise "must implement"
      end
    end
  end
end
