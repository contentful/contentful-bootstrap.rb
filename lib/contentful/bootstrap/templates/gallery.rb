require 'contentful/bootstrap/templates/base'
require 'contentful/bootstrap/templates/links'

module Contentful
  module Bootstrap
    module Templates
      class Gallery < Base
        def content_types
          [
            {
              'id' => 'author',
              'name' => 'Author',
              'displayField' => 'name',
              'fields' => [
                {
                  'name' => 'Name',
                  'id' => 'name',
                  'type' => 'Symbol'
                }
              ]
            },
            {
              'id' => 'image',
              'name' => 'Image',
              'displayField' => 'title',
              'fields' => [
                {
                  'id' => 'title',
                  'name' => 'Title',
                  'type' => 'Symbol'
                },
                {
                  'id' => 'photo',
                  'name' => 'Photo',
                  'type' => 'Link',
                  'linkType' => 'Asset'
                }
              ]
            },
            {
              'id' => 'gallery',
              'name' => 'Gallery',
              'displayField' => 'title',
              'fields' => [
                {
                  'id' => 'title',
                  'name' => 'Title',
                  'type' => 'Symbol'
                },
                {
                  'id' => 'author',
                  'name' => 'Author',
                  'type' => 'Link',
                  'linkType' => 'Entry'
                },
                {
                  'id' => 'images',
                  'name' => 'Images',
                  'type' => 'Array',
                  'items' => {
                    'type' => 'Link',
                    'linkType' => 'Entry'
                  }
                }
              ]
            }
          ]
        end

        def assets
          [
            {
              'id' => 'pie',
              'title' => 'Pie in the Sky',
              'file' => create_file('pie.jpg', 'https://c2.staticflickr.com/6/5245/5335909339_d307a7cbcf_b.jpg')
            },
            {
              'id' => 'flower',
              'title' => 'The Flower',
              'file' => create_file('flower.jpg', 'http://c2.staticflickr.com/4/3922/15045568809_b24591e318_b.jpg')
            }
          ]
        end

        def entries
          {
            'author' => [
              {
                'id' => 'dave',
                'name' => 'Dave'
              }
            ],
            'image' => [
              {
                'id' => 'pie_entry',
                'title' => 'A Pie in the Sky',
                'photo' => Links::Asset.new('pie')
              },
              {
                'id' => 'flower_entry',
                'title' => 'The Flower',
                'photo' => Links::Asset.new('flower')
              }
            ],
            'gallery' => [
              {
                'id' => 'gallery',
                'title' => 'Photo Gallery',
                'author' => Links::Entry.new('dave'),
                'images' => [Links::Entry.new('pie_entry'), Links::Entry.new('flower_entry')]
              }
            ]
          }
        end
      end
    end
  end
end
