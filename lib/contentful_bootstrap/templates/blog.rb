require "contentful_bootstrap/templates/base"
require "contentful_bootstrap/templates/entry_link"

module ContentfulBootstrap
  module Templates
    class Blog < Base
      def content_types
        [
          {
            id: 'author',
            name: 'Author',
            display_field: 'name',
            fields: [
              {
                id: 'name',
                name: "Author Name",
                type: "Symbol"
              }
            ]
          },
          {
            id: 'post',
            name: 'Post',
            display_field: 'title',
            fields: [
              {
                id: 'title',
                name: "Post Title",
                type: "Symbol"
              },
              {
                id: 'content',
                name: "Content",
                type: "Text"
              },
              {
                id: 'author',
                name: "Author",
                type: "Link",
                link_type: "Entry"
              }
            ]
          }
        ]
      end

      def entries
        {
          'author' => [
            {
              id: "dan_brown",
              name: "Dan Brown"
            },
            {
              id: "pablo_neruda",
              name: "Pablo Neruda"
            }
          ],
          'post' => [
            {
              title: "Inferno",
              content: "Inferno is the last book in Dan Brown's collection...",
              author: EntryLink.new("dan_brown")
            },
            {
              title: "Alturas de Macchu Picchu",
              content: "Alturas de Macchu Picchu is one of Pablo Neruda's most famous poetry books...",
              author: EntryLink.new("pablo_neruda")
            }
          ]
        }
      end
    end
  end
end
