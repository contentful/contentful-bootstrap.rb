require 'spec_helper'

describe Contentful::Bootstrap::Commands::CreateSpace do
  let(:path) { File.expand_path(File.join('spec', 'fixtures', 'ini_fixtures', 'contentfulrc.ini')) }
  let(:token) { Contentful::Bootstrap::Token.new path }
  subject { described_class.new token, 'foo', template: 'bar', json_template: 'baz', trigger_oauth: false, quiet: true }
  let(:space_double) { SpaceDouble.new }

  before do
    allow(::File).to receive(:write)
  end

  describe 'instance methods' do
    describe '#run' do
      it 'with all non nil attributes' do
        expect(subject).to receive(:fetch_space) { space_double }
        expect(subject).to receive(:create_template).with(space_double)
        expect(subject).to receive(:create_json_template).with(space_double)
        expect(subject).to receive(:generate_token).with(space_double)

        subject.run
      end

      it 'does not create template when template_name is nil' do
        create_space_command = described_class.new(token, 'foo', json_template: 'baz', trigger_oauth: false, quiet: true)

        expect(create_space_command.template_name).to eq nil

        expect(create_space_command).to receive(:fetch_space) { space_double }
        expect(create_space_command).not_to receive(:create_template).with(space_double)
        expect(create_space_command).to receive(:create_json_template).with(space_double)
        expect(create_space_command).to receive(:generate_token).with(space_double)

        create_space_command.run
      end

      it 'does not create json template when json_template is nil' do
        create_space_command = described_class.new(token, 'foo', template: 'bar', trigger_oauth: false, quiet: true)

        expect(create_space_command.json_template).to eq nil

        expect(create_space_command).to receive(:fetch_space) { space_double }
        expect(create_space_command).to receive(:create_template).with(space_double)
        expect(create_space_command).not_to receive(:create_json_template).with(space_double)
        expect(create_space_command).to receive(:generate_token).with(space_double)

        create_space_command.run
      end
    end
  end

  describe 'attributes' do
    it ':template_name' do
      expect(subject.template_name).to eq 'bar'
    end

    it ':json_template' do
      expect(subject.json_template).to eq 'baz'
    end
  end

  describe 'localization' do
    it 'can create a space with a different locale' do
      allow(Contentful::Bootstrap::Support).to receive(:gets).and_return('y')
      allow(Contentful::Bootstrap::Support).to receive(:gets).and_return('n')

      command = described_class.new(token, 'B.rb - locale creation', locale: 'es-AR')

      vcr('space_with_different_locale') {
        command.run
      }

      vcr('check_created_space') {
        client = ::Contentful::Client.new(
          space: 'vsy1ouf6jdcq',
          access_token: '90e1b4964c3631cc9c751c42339814635623b001a53aec5aad23377299445433',
          dynamic_entries: :auto,
          raise_errors: true
        )

        space = client.space

        expect(space.name).to eq("B.rb - locale creation")
        expect(space.locales.first.code).to eq "es-AR"
        expect(space.locales.first.default).to be_truthy
      }
    end
  end

  describe 'issues' do
    it 'Importing asset array values does not work #22' do
      json_path = File.expand_path(File.join('spec', 'fixtures', 'json_fixtures', 'issue_22.json'))

      allow(Contentful::Bootstrap::Support).to receive(:gets).and_return('y')
      allow(Contentful::Bootstrap::Support).to receive(:gets).and_return('n')

      command = described_class.new(token, 'issue_22', json_template: json_path, quiet: true)

      vcr('issue_22') {
        command.run
      }
    end

    it 'assets can be created with any content type #39' do
      json_path = File.expand_path(File.join('spec', 'fixtures', 'json_fixtures', 'asset_no_transform.json'))

      allow(Contentful::Bootstrap::Support).to receive(:gets).and_return('y')
      allow(Contentful::Bootstrap::Support).to receive(:gets).and_return('n')

      command = described_class.new(token, 'asset_no_transform', json_template: json_path, mark_processed: false, quiet: true)

      vcr('asset_no_transform') {
        command.run
      }
    end

    it 'doesnt fail on multiple organizations #54' do
      vcr('multiple_organizations') {
        path = File.expand_path(File.join('spec', 'fixtures', 'ini_fixtures', 'no_org.ini'))
        token = Contentful::Bootstrap::Token.new path

        allow(Contentful::Bootstrap::Support).to receive(:gets).and_return('y')
        allow(Contentful::Bootstrap::Support).to receive(:gets).and_return('n')
        subject = described_class.new token, 'foo', quiet: true

        expect(subject).to receive(:generate_token).with(space_double)
        expect(Contentful::Bootstrap::Support).to receive(:gets) { 'foobar' }
        expect(token).to receive(:write_organization_id).with('foobar')
        expect(subject.client).to receive(:spaces).and_call_original
        space_proxy_double = Object.new
        expect(subject.client).to receive(:spaces) { space_proxy_double }
        expect(space_proxy_double).to receive(:create).with(name: 'foo', defaultLocale: 'en-US', organization_id: 'foobar') { space_double }

        subject.run
      }
    end

    context 'with no_publish set to true' do
      subject { described_class.new token, 'foo', environment: 'master', json_template: 'bar', trigger_oauth: false, quiet: true, no_publish: true }

      it 'calls JsonTemplate with no_publish' do
        allow(Contentful::Bootstrap::Support).to receive(:gets).and_return('y')
        allow(Contentful::Bootstrap::Support).to receive(:gets).and_return('n')
        allow(::File).to receive(:exist?) { true }

        mock_template = Object.new

        expect(subject).to receive(:fetch_space) { space_double }
        expect(mock_template).to receive(:run)

        expect(::Contentful::Bootstrap::Templates::JsonTemplate).to receive(:new).with(space_double, 'bar', 'master', false, true, true, false, true) { mock_template }

        subject.run
      end
    end
  end

  describe 'integration' do
    before do
      allow(Contentful::Bootstrap::Support).to receive(:gets).and_return('y')
      allow(Contentful::Bootstrap::Support).to receive(:gets).and_return('n')
    end

    it 'create space' do
      command = described_class.new token, 'some_space', quiet: true

      vcr('create_space') {
        command.run
      }
    end

    it 'create space with blog template' do
      command = described_class.new token, 'blog_space', template: 'blog', quiet: true

      vcr('create_space_with_blog_template') {
        command.run
      }
    end

    it 'create space with gallery template' do
      command = described_class.new token, 'gallery_space', template: 'gallery', quiet: true

      vcr('create_space_with_gallery_template') {
        command.run
      }
    end

    it 'create space with catalogue template' do
      command = described_class.new token, 'catalogue_space', template: 'catalogue', quiet: true

      vcr('create_space_with_catalogue_template') {
        command.run
      }
    end

    it 'create space with json template' do
      skip 'covered by create_space_spec:issues/#22'
    end

    it 'create space with json template with no ids' do
      json_path = File.expand_path(File.join('spec', 'fixtures', 'json_fixtures', 'no_ids.json'))
      command = described_class.new token, 'no_ids_space', json_template: json_path, quiet: true

      vcr('no_ids') {
        command.run
      }
    end
  end
end
