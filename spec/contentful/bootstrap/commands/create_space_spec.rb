require 'spec_helper'

describe Contentful::Bootstrap::Commands::CreateSpace do
  let(:path) { File.expand_path(File.join('spec', 'fixtures', 'ini_fixtures', 'contentfulrc.ini')) }
  let(:token) { Contentful::Bootstrap::Token.new path }
  subject { Contentful::Bootstrap::Commands::CreateSpace.new token, 'foo', 'bar', 'baz', false }
  let(:space_double) { SpaceDouble.new }

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
        create_space_command = subject.class.new(token, 'foo', nil, 'baz', false)

        expect(create_space_command.template_name).to eq nil

        expect(create_space_command).to receive(:fetch_space) { space_double }
        expect(create_space_command).not_to receive(:create_template).with(space_double)
        expect(create_space_command).to receive(:create_json_template).with(space_double)
        expect(create_space_command).to receive(:generate_token).with(space_double)

        create_space_command.run
      end

      it 'does not create json template when json_template is nil' do
        create_space_command = subject.class.new(token, 'foo', 'bar', nil, false)

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

  describe 'issues' do
    it 'Importing asset array values does not work #22' do
      json_path = File.expand_path(File.join('spec', 'fixtures', 'json_fixtures', 'issue_22.json'))

      allow_any_instance_of(subject.class).to receive(:gets).and_return('y')
      allow_any_instance_of(Contentful::Bootstrap::Commands::GenerateToken).to receive(:gets).and_return('n')

      command = subject.class.new(token, 'issue_22', nil, json_path)

      vcr('issue_22') {
        command.run
      }
    end
  end

  describe 'integration' do
    before do
      allow_any_instance_of(subject.class).to receive(:gets).and_return('y')
      allow_any_instance_of(Contentful::Bootstrap::Commands::GenerateToken).to receive(:gets).and_return('n')
    end

    it 'create space' do
      command = subject.class.new token, 'some_space'

      vcr('create_space') {
        command.run
      }
    end

    it 'create space with blog template' do
      command = subject.class.new token, 'blog_space', 'blog'

      vcr('create_space_with_blog_template') {
        command.run
      }
    end

    it 'create space with gallery template' do
      command = subject.class.new token, 'gallery_space', 'gallery'

      vcr('create_space_with_gallery_template') {
        command.run
      }
    end

    it 'create space with catalogue template' do
      command = subject.class.new token, 'catalogue_space', 'catalogue'

      vcr('create_space_with_catalogue_template') {
        command.run
      }
    end

    it 'create space with json template' do
      skip 'covered by create_space_spec:issues/#22'
    end
  end
end
