require 'spec_helper'

class ResponseDouble
  def object
    {'accessToken' => 'foo'}
  end
end

class ErrorDouble < Contentful::Management::Error
  def initialize
  end

  def object
    self.class.new
  end
end

describe Contentful::Bootstrap::Commands::GenerateToken do
  let(:path) { File.expand_path(File.join('spec', 'fixtures', 'ini_fixtures', 'contentfulrc.ini')) }
  let(:token) { Contentful::Bootstrap::Token.new path }
  subject { described_class.new token, 'foo', token_name: 'bar', trigger_oauth: false, quiet: true }
  let(:space_double) { SpaceDouble.new }

  describe 'instance methods' do
    before do
      subject.send(:management_client_init)
    end

    describe '#run' do
      it 'fetches space from api if space is a string' do
        allow(Contentful::Bootstrap::Support).to receive(:gets) { 'n' }
        allow_any_instance_of(Contentful::Management::Request).to receive(:post) { ResponseDouble.new }
        expect(Contentful::Management::Space).to receive(:find).with('foo') { space_double }

        subject.run
      end

      it 'uses space if space is not a string' do
        allow(Contentful::Bootstrap::Support).to receive(:gets) { 'n' }
        allow_any_instance_of(Contentful::Management::Request).to receive(:post) { ResponseDouble.new }
        expect(Contentful::Management::Space).not_to receive(:find).with('foo') { space_double }

        subject.instance_variable_set(:@actual_space, space_double)

        subject.run
      end

      it 'returns access token' do
        allow(Contentful::Bootstrap::Support).to receive(:gets) { 'n' }
        allow_any_instance_of(Contentful::Management::Request).to receive(:post) { ResponseDouble.new }
        allow(Contentful::Management::Space).to receive(:find).with('foo') { space_double }

        expect(subject.run).to eq 'foo'
      end

      it 'fails if API returns an error' do
        allow(Contentful::Bootstrap::Support).to receive(:gets) { 'n' }
        allow_any_instance_of(Contentful::Management::Request).to receive(:post) { ErrorDouble.new }
        allow(Contentful::Management::Space).to receive(:find).with('foo') { space_double }

        expect { subject.run }.to raise_error ErrorDouble
      end

      it 'token gets written if user input is other than no' do
        allow(Contentful::Bootstrap::Support).to receive(:gets) { 'y' }
        allow_any_instance_of(Contentful::Management::Request).to receive(:post) { ResponseDouble.new }
        allow(Contentful::Management::Space).to receive(:find).with('foo') { space_double }

        expect(token).to receive(:write_access_token).with('foobar', 'foo')
        expect(token).to receive(:write_space_id).with('foobar', 'foobar')

        subject.run
      end
    end
  end

  describe 'attributes' do
    it ':token_name' do
      expect(subject.token_name).to eq 'bar'
    end
  end

  describe 'integration' do
    before do
      allow(Contentful::Bootstrap::Support).to receive(:gets).and_return('n')
    end

    it 'generates a token for a given space' do
      command = described_class.new token, 'zred3m25k5em', token_name: 'foo', quiet: true

      vcr('generate_token') {
        command.run
      }
    end
  end
end
