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
              'display_field' => 'name',
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
              'display_field' => 'title',
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
                  'link_type' => 'Asset'
                }
              ]
            },
            {
              'id' => 'gallery',
              'name' => 'Gallery',
              'display_field' => 'title',
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
                  'link_type' => 'Entry'
                },
                {
                  'id' => 'images',
                  'name' => 'Images',
                  'type' => 'Array',
                  'items' => {
                    'type' => 'Link',
                    'link_type' => 'Entry'
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
              'file' => create_image('pie', 'https://c2.staticflickr.com/6/5245/5335909339_d307a7cbcf_b.jpg')
            },
            {
              'id' => 'flower',
              'title' => 'The Flower',
              'file' => create_image('flower', 'http://c2.staticflickr.com/4/3922/15045568809_b24591e318_b.jpg')
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
