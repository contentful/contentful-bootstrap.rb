require 'spec_helper'

describe Contentful::Bootstrap::CommandRunner do
  let(:path) { File.expand_path(File.join('spec', 'fixtures', 'ini_fixtures', 'contentfulrc.ini')) }
  subject { Contentful::Bootstrap::CommandRunner.new(path) }

  describe 'instance methods' do
    describe '#create_space' do
      before do
        allow_any_instance_of(Contentful::Bootstrap::Commands::CreateSpace).to receive(:run)
      end

      it 'default values' do
        expect(Contentful::Bootstrap::Commands::CreateSpace).to receive(:new).with(
          subject.token, 'foo', {}
        ).and_call_original

        subject.create_space('foo')
      end

      it 'with options' do
        expect(Contentful::Bootstrap::Commands::CreateSpace).to receive(:new).with(
          subject.token, 'foo', template: 'bar', json_template: 'baz', mark_processed: true, trigger_oauth: false
        ).and_call_original

        subject.create_space('foo', template: 'bar', json_template: 'baz', mark_processed: true, trigger_oauth: false)
      end

      it 'runs command' do
        expect_any_instance_of(Contentful::Bootstrap::Commands::CreateSpace).to receive(:run)

        subject.create_space('foo', template: 'bar', json_template: 'baz', trigger_oauth: false)
      end
    end

    describe '#update_space' do
      before do
        allow_any_instance_of(Contentful::Bootstrap::Commands::UpdateSpace).to receive(:run)
      end

      it 'default values' do
        expect(Contentful::Bootstrap::Commands::UpdateSpace).to receive(:new).with(
          subject.token, 'foo', {}
        ).and_call_original

        subject.update_space('foo')
      end

      it 'with options' do
        expect(Contentful::Bootstrap::Commands::UpdateSpace).to receive(:new).with(
          subject.token, 'foo', json_template: 'bar', mark_processed: true, trigger_oauth: false
        ).and_call_original

        subject.update_space('foo', json_template: 'bar', mark_processed: true, trigger_oauth: false)
      end

      it 'runs command' do
        expect_any_instance_of(Contentful::Bootstrap::Commands::UpdateSpace).to receive(:run)

        subject.update_space('foo', json_template: 'bar', trigger_oauth: false)
      end
    end

    describe '#generate_token' do
      before do
        allow_any_instance_of(Contentful::Bootstrap::Commands::GenerateToken).to receive(:run)
        allow_any_instance_of(Contentful::Bootstrap::Commands::GenerateToken).to receive(:fetch_space)
      end

      it 'default values' do
        expect(Contentful::Bootstrap::Commands::GenerateToken).to receive(:new).with(
          subject.token, 'foo', {}
        ).and_call_original

        subject.generate_token('foo')
      end

      it 'with options' do
        expect(Contentful::Bootstrap::Commands::GenerateToken).to receive(:new).with(
          subject.token, 'foo', name: 'bar', trigger_oauth: false
        ).and_call_original

        subject.generate_token('foo', name: 'bar', trigger_oauth: false)
      end

      it 'runs command' do
        expect_any_instance_of(Contentful::Bootstrap::Commands::GenerateToken).to receive(:run)

        subject.generate_token('foo', name: 'bar', trigger_oauth: false)
      end
    end

    describe '#generate_json' do
      it 'requires access token to run' do
        expect {
          subject.generate_json('foo')
        }.to raise_error('Access Token required')
      end

      it 'default values' do
        allow_any_instance_of(Contentful::Bootstrap::Commands::GenerateJson).to receive(:run)

        expect(Contentful::Bootstrap::Commands::GenerateJson).to receive(:new).with(
          'foo', 'bar', 'master', nil, false, false, false, []
        ).and_call_original

        subject.generate_json('foo', access_token: 'bar')
      end

      it 'with options' do
        allow_any_instance_of(Contentful::Bootstrap::Commands::GenerateJson).to receive(:run)

        expect(Contentful::Bootstrap::Commands::GenerateJson).to receive(:new).with(
          'foo', 'bar', 'master', 'baz', true, false, false, []
        ).and_call_original

        subject.generate_json('foo', access_token: 'bar', filename: 'baz', content_types_only: true)
      end

      it 'runs command' do
        expect_any_instance_of(Contentful::Bootstrap::Commands::GenerateJson).to receive(:run)

        subject.generate_json('foo', access_token: 'bar', filename: 'baz')
      end
    end
  end

  describe 'attributes' do
    it ':config_path' do
      expect(subject.config_path).to eq path
    end

    it ':token' do
      expect(subject.token == Contentful::Bootstrap::Token.new(path)).to be_truthy
    end
  end
end
