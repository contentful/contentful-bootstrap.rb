require 'contentful/bootstrap/templates/base'
require 'contentful/bootstrap/templates/links'

module Contentful
  module Bootstrap
    module Templates
      class Catalogue < Base
        def content_types
          [
            {
              'id' => 'brand',
              'name' => 'Brand',
              'displayField' => 'name',
              'fields' => [
                {
                  'id' => 'name',
                  'name' => 'Company Name',
                  'type' => 'Symbol'
                },
                {
                  'id' => 'website',
                  'name' => 'Website',
                  'type' => 'Symbol'
                },
                {
                  'id' => 'logo',
                  'name' => 'Logo',
                  'type' => 'Link',
                  'linkType' => 'Asset'
                }
              ]
            },
            {
              'id' => 'category',
              'name' => 'Category',
              'displayField' => 'title',
              'fields' => [
                {
                  'id' => 'title',
                  'name' => 'Title',
                  'type' => 'Symbol'
                },
                {
                  'id' => 'description',
                  'name' => 'Description',
                  'type' => 'Text'
                },
                {
                  'id' => 'icon',
                  'name' => 'Icon',
                  'type' => 'Link',
                  'linkType' => 'Asset'
                }
              ]
            },
            {
              'id' => 'product',
              'name' => 'Product',
              'displayField' => 'name',
              'fields' => [
                {
                  'id' => 'name',
                  'name' => 'name',
                  'type' => 'Symbol'
                },
                {
                  'id' => 'description',
                  'name' => 'Description',
                  'type' => 'Text'
                },
                {
                  'id' => 'image',
                  'name' => 'Image',
                  'type' => 'Link',
                  'linkType' => 'Asset'
                },
                {
                  'id' => 'brand',
                  'name' => 'Brand',
                  'type' => 'Link',
                  'linkType' => 'Entry'
                },
                {
                  'id' => 'category',
                  'name' => 'Category',
                  'type' => 'Link',
                  'linkType' => 'Entry'
                },
                {
                  'id' => 'url',
                  'name' => 'Available at',
                  'type' => 'Symbol'
                }
              ]
            }
          ]
        end

        def assets
          [
            {
              'id' => 'playsam_image',
              'title' => 'Playsam',
              'file' => create_file('playsam_image.jpg', 'https://images.contentful.com/liicpxzmg1q0/4zj1ZOfHgQ8oqgaSKm4Qo2/3be82d54d45b5297e951aee9baf920da/playsam.jpg?h=250&')
            },
            {
              'id' => 'normann_image',
              'title' => 'Normann',
              'file' => create_file('normann_image.jpg', 'https://images.contentful.com/liicpxzmg1q0/3wtvPBbBjiMKqKKga8I2Cu/75c7c92f38f7953a741591d215ad61d4/zJYzDlGk.jpeg?h=250&')
            },
            {
              'id' => 'toy_image',
              'title' => 'Toys',
              'file' => create_file('toy_image.jpg', 'https://images.contentful.com/liicpxzmg1q0/6t4HKjytPi0mYgs240wkG/866ef53a11af9c6bf5f3808a8ce1aab2/toys_512pxGREY.png?h=250&')
            },
            {
              'id' => 'kitchen_image',
              'title' => 'Kitchen and Home',
              'file' => create_file('kitchen_image.jpg', 'https://images.contentful.com/liicpxzmg1q0/6m5AJ9vMPKc8OUoQeoCS4o/ffc20f5a8f2a71cca4801bc9c51b966a/1418244847_Streamline-18-256.png?h=250&')
            },
            {
              'id' => 'toy_car',
              'title' => 'Playsam Toy Car',
              'file' => create_file('toy_car.jpg', 'https://images.contentful.com/liicpxzmg1q0/wtrHxeu3zEoEce2MokCSi/acef70d12fe019228c4238aa791bdd48/quwowooybuqbl6ntboz3.jpg?h=250&')
            },
            {
              'id' => 'whiskers',
              'title' => 'Normann Whisk Beaters',
              'file' => create_file('whiskers.jpg', 'https://images.contentful.com/liicpxzmg1q0/10TkaLheGeQG6qQGqWYqUI/d510dde5e575d40288cf75b42383aa53/ryugj83mqwa1asojwtwb.jpg?h=250&')
            }
          ]
        end

        def entries
          {
            'brand' => [
              {
                'id' => 'playsam',
                'name' => 'Playsam, Inc',
                'website' => 'http://www.playsam.com',
                'logo' => Links::Asset.new('playsam_image')
              },
              {
                'id' => 'normann',
                'name' => 'Normann Copenhagen, Inc',
                'website' => 'http://www.normann-copenhagen.com/',
                'logo' => Links::Asset.new('normann_image')
              }
            ],
            'category' => [
              {
                'id' => 'toys',
                'title' => 'Toys',
                'description' => 'Toys for children',
                'icon' => Links::Asset.new('toy_image')
              },
              {
                'id' => 'kitchen',
                'title' => 'House and Kitchen',
                'description' => 'House and Kitchen accessories',
                'icon' => Links::Asset.new('kitchen_image')
              }
            ],
            'product' => [
              {
                'id' => 'playsam_car',
                'name' => 'Playsam Streamliner Classic Car, Espresso',
                'description' => 'A classic Playsam design, the Streamliner Classic Car has been selected as Swedish Design Classic by the Swedish National Museum for its inventive style and sleek surface. It\'s no wonder that this wooden car has also been a long-standing favorite for children both big and small!',
                'image' => Links::Asset.new('toy_car'),
                'brand' => Links::Entry.new('playsam'),
                'category' => Links::Entry.new('toys'),
                'url' => 'http://www.amazon.com/dp/B001R6JUZ2/'
              },
              {
                'id' => 'whisk_beater',
                'name' => 'Whisk Beater',
                'description' => 'A creative little whisk that comes in 8 different colors. Handy and easy to clean after use. A great gift idea.',
                'image' => Links::Asset.new('whiskers'),
                'brand' => Links::Entry.new('normann'),
                'category' => Links::Entry.new('kitchen'),
                'url' => 'http://www.amazon.com/dp/B0081F2CCK/'
              }
            ]
          }
        end
      end
    end
  end
end
