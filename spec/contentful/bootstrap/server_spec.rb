require 'spec_helper'

describe Contentful::Bootstrap::OAuthEchoView do
  describe 'instance methods' do
    it '#render' do
      expect(subject.render).to include(
        'html',
        'script',
        'access_token',
        'window.location.replace',
        'save_token'
      )
    end
  end
end

describe Contentful::Bootstrap::ThanksView do
  describe 'instance methods' do
    it '#render' do
      expect(subject.render).to include(
        'html',
        'Contentful Bootstrap',
        'Thanks!'
      )
    end
  end
end

describe Contentful::Bootstrap::IndexController do
  subject { Contentful::Bootstrap::IndexController.new(ServerDouble.new) }

  describe 'instance methods' do
    describe '#do_GET' do
      it 'launches browser' do
        expect(Launchy).to receive(:open)
        subject.do_GET(RequestDouble.new, ResponseDouble.new)
      end
    end
  end
end

describe Contentful::Bootstrap::OAuthCallbackController do
  subject { Contentful::Bootstrap::OAuthCallbackController.new(ServerDouble.new) }
  let(:response_double) { ResponseDouble.new }

  describe 'instance methods' do
    describe '#do_GET' do
      it 'renders OAuthEchoView' do
        subject.do_GET(RequestDouble.new, response_double)
        expect(response_double.body).to eq Contentful::Bootstrap::OAuthEchoView.new.render
      end
    end
  end
end

describe Contentful::Bootstrap::SaveTokenController do
  let(:path) { File.expand_path(File.join('spec', 'fixtures', 'ini_fixtures', 'contentfulrc.ini')) }
  let(:token) { Contentful::Bootstrap::Token.new path }
  subject { Contentful::Bootstrap::SaveTokenController.new(ServerDouble.new, token) }
  let(:response_double) { ResponseDouble.new }
  let(:request_double) { RequestDouble.new }

  describe 'instance methods' do
    describe '#do_GET' do
      it 'writes token' do
        request_double.query = {'token' => 'foo'}

        expect(token).to receive(:write).with('foo')

        subject.do_GET(request_double, response_double)
      end

      it 'renders ThanksView' do
        request_double.query = {'token' => 'foo'}
        allow(token).to receive(:write)

        subject.do_GET(request_double, response_double)

        expect(response_double.body).to eq Contentful::Bootstrap::ThanksView.new.render
      end
    end
  end

  describe 'attributes' do
    it ':token' do
      expect(subject.token).to eq token
    end
  end
end

describe Contentful::Bootstrap::Server do
  let(:path) { File.expand_path(File.join('spec', 'fixtures', 'ini_fixtures', 'contentfulrc.ini')) }
  let(:token) { Contentful::Bootstrap::Token.new path }
  subject { Contentful::Bootstrap::Server.new(token) }

  before do
    allow_any_instance_of(WEBrick::HTTPServer).to receive(:start)
    allow(WEBrick::Utils).to receive(:create_listeners) { [] } # Mock TCP Port binding
  end

  describe 'instance methods' do
    describe '#start' do
      it 'runs server in a new thread' do
        expect(Thread).to receive(:new)
        subject.start
      end
    end

    describe '#stop' do
      it 'shutdowns webrick' do
        expect(subject.server).to receive(:shutdown)
        subject.stop
      end
    end

    describe '#running?' do
      it 'returns true if webrick is running' do
        expect(subject.server).to receive(:status) { :Running }
        expect(subject.running?).to be_truthy
      end

      it 'returns false if webrick is not running' do
        expect(subject.server).to receive(:status) { :Stop }
        expect(subject.running?).to be_falsey
      end
    end
  end

  describe 'attributes' do
    describe ':server' do
      it 'creates the webrick server' do
        expect(subject.server).to be_kind_of(WEBrick::HTTPServer)
      end

      describe 'mounted endpoints' do
        before do
          @mount_table = subject.server.instance_variable_get(:@mount_tab)
        end

        it '/' do
          expect(@mount_table['/'][0]).to eq(Contentful::Bootstrap::IndexController)
        end

        it '/oauth_callback' do
          expect(@mount_table['/oauth_callback'][0]).to eq(Contentful::Bootstrap::OAuthCallbackController)
        end

        it '/save_token' do
          expect(@mount_table['/save_token'][0]).to eq(Contentful::Bootstrap::SaveTokenController)
        end
      end
    end
  end
end
