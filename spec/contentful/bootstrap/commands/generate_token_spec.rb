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
      subject.send(:client)
    end

    describe '#run' do
      it 'fetches space from api if space is a string' do
        allow(Contentful::Bootstrap::Support).to receive(:gets) { 'n' }
        expect_any_instance_of(Contentful::Management::ClientSpaceMethodsFactory).to receive(:find).with('foo') { space_double }

        subject.run
      end

      it 'uses space if space is not a string' do
        allow(Contentful::Bootstrap::Support).to receive(:gets) { 'n' }
        expect_any_instance_of(Contentful::Management::ClientSpaceMethodsFactory).not_to receive(:find).with('foo') { space_double }
        subject.instance_variable_set(:@space, space_double)

        subject.run
      end

      it 'returns access token' do
        allow(Contentful::Bootstrap::Support).to receive(:gets) { 'n' }
        allow_any_instance_of(Contentful::Management::ClientSpaceMethodsFactory).to receive(:find).with('foo') { space_double }
        expect(space_double).to receive(:api_keys).and_call_original

        expect(subject.run).to eq 'random_api_key'
      end

      it 'fails if API returns an error' do
        allow(Contentful::Bootstrap::Support).to receive(:gets) { 'n' }
        allow_any_instance_of(Contentful::Management::ClientSpaceMethodsFactory).to receive(:find).with('foo') { space_double }
        expect(space_double).to receive(:api_keys).and_raise(ErrorDouble.new)

        expect { subject.run }.to raise_error ErrorDouble
      end

      it 'token gets written if user input is other than no' do
        allow(Contentful::Bootstrap::Support).to receive(:gets) { 'y' }
        allow_any_instance_of(Contentful::Management::ClientSpaceMethodsFactory).to receive(:find).with('foo') { space_double }
        expect(space_double).to receive(:api_keys).and_call_original

        expect(token).to receive(:write_access_token).with('foobar', 'random_api_key')
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
