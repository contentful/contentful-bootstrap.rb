require 'spec_helper'

describe Contentful::Bootstrap::Templates::JsonTemplate do
  let(:space) { Contentful::Management::Space.new }
  let(:path) { json_path('simple') }
  subject { described_class.new space, path, 'master', false, true, true }

  before :each do
    environment_proxy = Object.new
    allow(space).to receive(:environments) { environment_proxy }

    environment = Object.new
    allow(environment_proxy).to receive(:find) { environment }
  end

  before do
    allow(::File).to receive(:write)
  end

  describe 'instance methods' do
    describe '#content_types' do
      it 'fetches content types' do
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

      it 'uses displayField if found' do
        expect(subject.content_types.first['displayField']).to eq 'name'
      end

      it 'uses display_field if not' do
        subject = described_class.new(space, File.expand_path(File.join('spec', 'fixtures', 'json_fixtures', 'display_field.json')), 'master', false, true, true)

        expect(subject.content_types.first['displayField']).to eq 'name'
      end
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
    let(:invalid_version_path) { json_path('invalid') }
    let(:low_version_path) { json_path('low') }
    let(:high_version_path) { json_path('high') }
    let(:ok_version_path) { json_path('ok_version') }

    it 'rejects templates without version' do
      expect { described_class.new space, invalid_version_path }.to raise_error "JSON Templates Version Mismatch. Current Version: 3"
    end

    it 'rejects templates with previous versions' do
      expect { described_class.new space, low_version_path }.to raise_error "JSON Templates Version Mismatch. Current Version: 3"
    end

    it 'rejects templates with newer versions' do
      expect { described_class.new space, high_version_path }.to raise_error "JSON Templates Version Mismatch. Current Version: 3"
    end

    it 'accepts templates with correct version' do
      expect { described_class.new space, ok_version_path }.not_to raise_error
    end
  end

  describe 'issues' do
    let(:link_entry_path) { json_path('links') }
    let(:object_entry_path) { json_path('object') }

    it 'links are not properly getting processed - #33' do
      subject = described_class.new space, link_entry_path

      expect(subject.entries["cat"].first).to eq(
        {
          "id" => "foo",
          "link" => Contentful::Bootstrap::Templates::Links::Entry.new('foobar')
        }
      )
    end

    it 'allows templates with object fields to work - #51' do
      subject = described_class.new space, object_entry_path
      expect(subject.entries['test'].first).to eq(
        {
          "id" => "foo",
          "name" => "test",
          "object" => {
            "foo" => "bar",
            "baz" => "qux"
          }
        }
      )
    end
  end

  describe 'bootstrap processed' do
    let(:processed_path) { json_path('processed') }

    it 'filters content types that were already processed' do
      json_fixture('processed') { |json|
        expect(json['contentTypes'].size).to eq(2)
        expect(json['contentTypes'].last['id']).to eq('dog')

        subject = described_class.new(space, processed_path, 'master', false, false)

        expect(subject.content_types.size).to eq(1)
        expect(subject.content_types.first['id']).to eq('cat')
      }
    end

    it 'filters assets that were already processed' do
      json_fixture('processed') { |json|
        expect(json['assets'].size).to eq(2)
        expect(json['assets'].last['id']).to eq('dog_asset')

        subject = described_class.new(space, processed_path, 'master', false, false)

        expect(subject.assets.size).to eq(1)
        expect(subject.assets.first['id']).to eq('cat_asset')
      }
    end

    it 'filters entries that were already processed' do
      json_fixture('processed') { |json|
        expect(json['entries']['dog'].size).to eq(1)
        expect(json['entries']['dog'].first['sys']['id']).to eq('doge')

        subject = described_class.new(space, processed_path, 'master', false, false)

        expect(subject.entries['dog'].size).to eq(0)
      }
    end
  end

  describe 'mark processed' do
    it 'does not write file after run if not mark_processed' do
      subject = described_class.new(space, path, 'master', false, false)
      ['content_types', 'assets', 'entries'].each do |n|
        allow(subject).to receive("create_#{n}".to_sym)
      end

      expect(subject).to receive(:after_run).and_call_original
      expect(::File).not_to receive(:write)

      subject.run
    end

    it 'writes file after run if mark_processed' do
      subject = described_class.new(space, path, 'master', true, false)
      ['content_types', 'assets', 'entries'].each do |n|
        allow(subject).to receive("create_#{n}".to_sym)
      end

      expect(subject).to receive(:after_run).and_call_original

      expected = {
        "version": 3,
        "contentTypes": [
          {
            "id": "cat",
            "name": "Cat",
            "displayField": "name",
            "fields": [
              {
                "id": "name",
                "name": "Name",
                "type": "Symbol"
              }
            ],
            "bootstrapProcessed": true
          }
        ],
        "assets": [
          {
            "id": "cat_asset",
            "title": "Cat",
            "file": {
              "filename": "cat",
              "url": "https://somecat.com/my_cat.jpeg"
            },
            "bootstrapProcessed": true
          }
        ],
        "entries": {
          "cat": [
            {
              "sys": {
                "id": "nyancat",
                "bootstrapProcessed": true
              },
              "fields": {
                "name": "Nyan Cat"
              }
            }
          ]
        }
      }
      expect(::File).to receive(:write).with(path, JSON.pretty_generate(expected))

      subject.run
    end
  end

  describe 'skip_content_types' do
    context 'with skip_content_types set to true' do
      subject { described_class.new(space, path, 'master', false, false, true, true) }

      it 'skips content type creation' do
        ['assets', 'entries'].each do |n|
          expect(subject).to receive("create_#{n}".to_sym)
        end

        expect(subject).not_to receive(:create_content_types)

        allow(subject).to receive(:after_run)

        subject.run
      end
    end

    context 'with skip_content_types set to false' do
      subject { described_class.new(space, path, 'master', false, false, true, false) }

      it 'doesnt skip content type creation' do
        ['assets', 'entries', 'content_types'].each do |n|
          expect(subject).to receive("create_#{n}".to_sym)
        end

        allow(subject).to receive(:after_run)

        subject.run
      end
    end
  end
end
