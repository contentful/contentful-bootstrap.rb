require 'spec_helper'

describe Contentful::Bootstrap::Commands::UpdateSpace do
  let(:path) { File.expand_path(File.join('spec', 'fixtures', 'ini_fixtures', 'contentfulrc.ini')) }
  let(:token) { Contentful::Bootstrap::Token.new path }
  subject { Contentful::Bootstrap::Commands::UpdateSpace.new token, 'foo', 'bar', false, false }
  let(:space_double) { SpaceDouble.new }

  before do
    allow(::File).to receive(:write)
  end

  describe 'instance methods' do
    describe '#run' do
      it 'with all non nil attributes' do
        expect(subject).to receive(:fetch_space) { space_double }
        expect(subject).to receive(:update_json_template).with(space_double)

        expect(subject.run).to eq(space_double)
      end

      it 'exits if JSON not sent' do
        update_space_command = described_class.new(token, 'foo', nil, false)

        expect { update_space_command.run }.to raise_error SystemExit
      end

      it 'exits if space is not found' do
        update_space_command = described_class.new(token, 'foo', 'bar', false)

        expect(::Contentful::Management::Space).to receive(:find).with('foo').and_raise(::Contentful::Management::NotFound.new(ErrorRequestDouble.new))

        expect { update_space_command.run }.to raise_error SystemExit
      end

      it 'exits if JSON template is not an existing file' do
        expect(subject).to receive(:fetch_space) { space_double }

        expect { subject.run }.to raise_error SystemExit
      end

      describe 'runs JSON Template without already processed elements' do
        [true, false].each do |mark_processed|
          it (mark_processed ? 'marks as processed after run' : 'doesnt modify input file after done') do
            subject = described_class.new token, 'foo', 'bar', mark_processed, false

            allow(::File).to receive(:exist?) { true }

            mock_template = Object.new

            expect(subject).to receive(:fetch_space) { space_double }
            expect(mock_template).to receive(:run)

            expect(::Contentful::Bootstrap::Templates::JsonTemplate).to receive(:new).with(space_double, 'bar', mark_processed, false) { mock_template }

            subject.run
          end
        end
      end
    end
  end

  describe 'attributes' do
    it ':json_template' do
      expect(subject.json_template).to eq 'bar'
    end
  end
end
