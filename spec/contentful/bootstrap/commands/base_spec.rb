require 'spec_helper'
require 'net/http'
require 'contentful/bootstrap/commands/base'

describe Contentful::Bootstrap::Commands::Base do
  let(:path) { File.expand_path(File.join('spec', 'fixtures', 'ini_fixtures', 'contentfulrc.ini')) }
  let(:no_token_path) { File.expand_path(File.join('spec', 'fixtures', 'ini_fixtures', 'no_token.ini')) }
  let(:token) { Contentful::Bootstrap::Token.new path }
  let(:non_management_token) { Contentful::Bootstrap::Token.new no_token_path }
  subject { described_class.new(token, 'foo', trigger_oauth: false, quiet: true) }

  describe 'abstract methods' do
    it '#run' do
      expect { subject.run }.to raise_error 'must implement'
    end
  end

  describe 'initialize' do
    describe 'configuration' do
      it 'runs configuration when trigger_oauth is true' do
        expect_any_instance_of(described_class).to receive(:configuration)
        described_class.new(token, 'foo', quiet: true)
      end

      it 'doesnt run configuration when trigger_oauth is false' do
        expect_any_instance_of(described_class).not_to receive(:configuration)
        described_class.new(token, 'foo', trigger_oauth: false, quiet: true)
      end
    end
  end

  describe 'instance methods' do
    it '#client' do
      allow_any_instance_of(described_class).to receive(:configuration)
      expect(Contentful::Management::Client).to receive(:new).with(
        token.read,
        default_locale: 'en-US',
        raise_errors: true,
        application_name: 'bootstrap',
        application_version: Contentful::Bootstrap::VERSION
      )

      described_class.new(token, 'foo', quiet: true)
    end

    describe '#configuration' do
      before do
        allow_any_instance_of(subject.class).to receive(:client)
      end

      it 'passes if token is found' do
        expect { described_class.new(token, 'foo') }.to output("OAuth token found, moving on!\n").to_stdout
      end

      describe 'token not found' do
        it 'exits if answer is no' do
          expect(Contentful::Bootstrap::Support).to receive(:gets) { "n" }
          expect { described_class.new(non_management_token, 'foo', quiet: true) }.to raise_error SystemExit
        end

        it 'runs token_server if other answer' do
          expect(Contentful::Bootstrap::Support).to receive(:gets) { "y" }
          expect_any_instance_of(described_class).to receive(:token_server)

          described_class.new(non_management_token, 'foo', quiet: true)
        end
      end
    end

    it '#token_server' do
      allow_any_instance_of(described_class).to receive(:client)

      expect(Contentful::Bootstrap::Support).to receive(:gets) { "y" }
      expect_any_instance_of(Contentful::Bootstrap::Server).to receive(:start) {}
      expect_any_instance_of(Contentful::Bootstrap::Server).to receive(:running?) { true }
      expect(Net::HTTP).to receive(:get).with(URI('http://localhost:5123')) {}
      expect(non_management_token).to receive(:present?).and_return(false, true)
      expect_any_instance_of(Contentful::Bootstrap::Server).to receive(:stop) {}

      described_class.new(non_management_token, 'foo', quiet: true)
    end
  end

  describe 'attributes' do
    it ':space' do
      expect(subject.space).to eq 'foo'
    end

    it ':token' do
      expect(subject.token == Contentful::Bootstrap::Token.new(path)).to be_truthy
    end
  end

  describe 'additional options' do
    describe ':no_input' do
      it ':no_input will disallow all input operations' do
        expect_any_instance_of(described_class).not_to receive(:token_server)
        expect(Contentful::Bootstrap::Support).not_to receive(:gets)
        expect { described_class.new(non_management_token, 'foo', quiet: true, no_input: true) }.to raise_error "OAuth token required to proceed"
      end

      it 'without :no_input input operations are allowed' do
        expect_any_instance_of(described_class).to receive(:token_server)
        expect(Contentful::Bootstrap::Support).to receive(:gets) { "y" }
        allow(non_management_token).to receive(:read) { true }
        described_class.new(non_management_token, 'foo', quiet: true, no_input: false)
      end
    end
  end
end
