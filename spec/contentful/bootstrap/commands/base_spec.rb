require 'spec_helper'
require 'net/http'
require 'contentful/bootstrap/commands/base'

describe Contentful::Bootstrap::Commands::Base do
  let(:path) { File.expand_path(File.join('spec', 'fixtures', 'ini_fixtures', 'contentfulrc.ini')) }
  let(:no_token_path) { File.expand_path(File.join('spec', 'fixtures', 'ini_fixtures', 'no_token.ini')) }
  let(:token) { Contentful::Bootstrap::Token.new path }
  let(:non_management_token) { Contentful::Bootstrap::Token.new no_token_path }
  subject { Contentful::Bootstrap::Commands::Base.new token, 'foo', false }

  describe 'abstract methods' do
    it '#run' do
      expect { subject.run }.to raise_error 'must implement'
    end
  end

  describe 'initialize' do
    describe 'configuration' do
      it 'runs configuration when trigger_oauth is true' do
        expect_any_instance_of(subject.class).to receive(:configuration)
        subject.class.new(token, 'foo')
      end

      it 'doesnt run configuration when trigger_oauth is false' do
        expect_any_instance_of(subject.class).not_to receive(:configuration)
        subject.class.new(token, 'foo', false)
      end
    end

    describe 'management_client_init' do
      it 'runs management_client_init when trigger_oauth is true' do
        expect_any_instance_of(subject.class).to receive(:management_client_init)
        subject.class.new(token, 'foo')
      end

      it 'doesnt run management_client_init when trigger_oauth is false' do
        expect_any_instance_of(subject.class).not_to receive(:management_client_init)
        subject.class.new(token, 'foo', false)
      end
    end
  end

  describe 'instance methods' do
    it '#management_client_init' do
      allow_any_instance_of(subject.class).to receive(:configuration)
      expect(Contentful::Management::Client).to receive(:new).with(token.read, raise_errors: true)

      subject.class.new(token, 'foo')
    end

    describe '#configuration' do
      before do
        allow_any_instance_of(subject.class).to receive(:management_client_init)
      end

      it 'passes if token is found' do
        expect { subject.class.new(token, 'foo') }.to output("OAuth token found, moving on!\n").to_stdout
      end

      describe 'token not found' do
        it 'exits if answer is no' do
          expect_any_instance_of(subject.class).to receive(:gets) { "n\n" }
          expect { subject.class.new(non_management_token, 'foo') }.to raise_error SystemExit
        end

        it 'runs token_server if other answer' do
          expect_any_instance_of(subject.class).to receive(:gets) { "y\n" }
          expect_any_instance_of(subject.class).to receive(:token_server)

          subject.class.new(non_management_token, 'foo')
        end
      end
    end

    it '#token_server' do
      allow_any_instance_of(subject.class).to receive(:management_client_init)

      expect_any_instance_of(subject.class).to receive(:gets) { "y\n" }
      expect_any_instance_of(Contentful::Bootstrap::Server).to receive(:start) {}
      expect_any_instance_of(Contentful::Bootstrap::Server).to receive(:running?) { true }
      expect(Net::HTTP).to receive(:get).with(URI('http://localhost:5123')) {}
      expect(non_management_token).to receive(:present?).and_return(false, true)
      expect_any_instance_of(Contentful::Bootstrap::Server).to receive(:stop) {}

      subject.class.new(non_management_token, 'foo')
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

  describe '#initialize' do
  end
end
