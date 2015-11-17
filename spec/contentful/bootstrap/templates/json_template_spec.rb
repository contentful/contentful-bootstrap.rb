require 'spec_helper'

describe Contentful::Bootstrap::Templates::JsonTemplate do
  let(:space) { Contentful::Management::Space.new }
  let(:path) { File.expand_path(File.join('spec', 'fixtures', 'json_fixtures', 'simple.json')) }
  subject { Contentful::Bootstrap::Templates::JsonTemplate.new space, path }

  describe 'instance methods' do
    it '#content_types' do
      expect(subject.content_types.first).to eq(
        {
          "id" => "cat",
          "name" => "Cat",
          "displayField" => "name",
          "fields" => [
            {
              "id" => "name",
              "name" => "Name",
              "type" => "Symbol"
            }
          ]
        }
      )

      expect(subject.content_types.size).to eq(1)
    end

    it '#assets' do
      expect(subject.assets.first).to include(
        {
          "id" => "cat_asset",
          "title" => "Cat"
        }
      )

      expect(subject.assets.first['file']).to be_kind_of(Contentful::Management::File)

      expect(subject.assets.size).to eq(1)
    end

    it '#entries' do
      expect(subject.entries.keys).to include("cat")
      expect(subject.entries["cat"].size).to eq(1)
      expect(subject.entries["cat"].first).to eq(
        {
          "id" => "nyancat",
          "name" => "Nyan Cat"
        }
      )
    end
  end
end
