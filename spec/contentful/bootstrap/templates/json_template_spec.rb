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

  describe 'template version check' do
    let(:invalid_version_path) { File.expand_path(File.join('spec', 'fixtures', 'json_fixtures', 'invalid.json')) }
    let(:low_version_path) { File.expand_path(File.join('spec', 'fixtures', 'json_fixtures', 'low.json')) }
    let(:high_version_path) { File.expand_path(File.join('spec', 'fixtures', 'json_fixtures', 'high.json')) }
    let(:ok_version_path) { File.expand_path(File.join('spec', 'fixtures', 'json_fixtures', 'ok_version.json')) }

    it 'rejects templates without version' do
      expect { described_class.new space, invalid_version_path }.to raise_error "JSON Templates Version Mismatch"
    end

    it 'rejects templates with previous versions' do
      expect { described_class.new space, low_version_path }.to raise_error "JSON Templates Version Mismatch"
    end

    it 'rejects templates with never versions' do
      expect { described_class.new space, high_version_path }.to raise_error "JSON Templates Version Mismatch"
    end

    it 'accepts templates with never versions' do
      expect { described_class.new space, ok_version_path }.not_to raise_error
    end
  end
end
