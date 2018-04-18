require 'spec_helper'

describe Contentful::Bootstrap::Commands::UpdateSpace do
  let(:path) { File.expand_path(File.join('spec', 'fixtures', 'ini_fixtures', 'contentfulrc.ini')) }
  let(:token) { Contentful::Bootstrap::Token.new path }
  subject { described_class.new token, 'foo', environment: 'master', json_template: 'bar', mark_processed: false, trigger_oauth: false, quiet: true }
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
        update_space_command = described_class.new(token, 'foo', mark_processed: false, quiet: true)

        expect { update_space_command.run }.to raise_error SystemExit
      end

      it 'exits if space is not found' do
        update_space_command = described_class.new(token, 'foo', json_template: 'bar', quiet: true)

        expect_any_instance_of(::Contentful::Management::ClientSpaceMethodsFactory).to receive(:find).with('foo').and_raise(::Contentful::Management::NotFound.new(ErrorRequestDouble.new))

        expect { update_space_command.run }.to raise_error SystemExit
      end

      it 'exits if JSON template is not an existing file' do
        expect(subject).to receive(:fetch_space) { space_double }

        expect { subject.run }.to raise_error SystemExit
      end

      describe 'runs JSON Template without already processed elements' do
        [true, false].each do |mark_processed|
          context "mark_processed is #{mark_processed}" do
            subject { described_class.new token, 'foo', environment: 'master', json_template: 'bar', mark_processed: mark_processed, trigger_oauth: false, quiet: true}

            it "calls JsonTemplate with mark_processed as #{mark_processed}" do
              allow(::File).to receive(:exist?) { true }

              mock_template = Object.new

              expect(subject).to receive(:fetch_space) { space_double }
              expect(mock_template).to receive(:run)

              expect(::Contentful::Bootstrap::Templates::JsonTemplate).to receive(:new).with(space_double, 'bar', 'master', mark_processed, true, true, false, false) { mock_template }

              subject.run
            end
          end
        end
      end

      context 'with skip_content_types set to true' do
        subject { described_class.new token, 'foo', json_template: 'bar', trigger_oauth: false, skip_content_types: true, quiet: true }

        it 'calls JsonTemplate with skip_content_types' do
          allow(::File).to receive(:exist?) { true }

          mock_template = Object.new

          expect(subject).to receive(:fetch_space) { space_double }
          expect(mock_template).to receive(:run)

          expect(::Contentful::Bootstrap::Templates::JsonTemplate).to receive(:new).with(space_double, 'bar', 'master', false, true, true, true, false) { mock_template }

          subject.run
        end
      end

      context 'with no_publish set to true' do
        subject { described_class.new token, 'foo', environment: 'master', json_template: 'bar', trigger_oauth: false, skip_content_types: true, quiet: true, no_publish: true }

        it 'calls JsonTemplate with no_publish' do
          allow(::File).to receive(:exist?) { true }

          mock_template = Object.new

          expect(subject).to receive(:fetch_space) { space_double }
          expect(mock_template).to receive(:run)

          expect(::Contentful::Bootstrap::Templates::JsonTemplate).to receive(:new).with(space_double, 'bar', 'master', false, true, true, true, true) { mock_template }

          subject.run
        end
      end
    end
  end

  describe 'attributes' do
    it ':json_template' do
      expect(subject.json_template).to eq 'bar'
    end
  end

  describe 'integration' do
    it 'can update localized spaces' do
      vcr('update_space_localized') {
        json_path = File.expand_path(File.join('spec', 'fixtures', 'json_fixtures', 'update_space_localized.json'))
        subject = described_class.new(token, 'vsy1ouf6jdcq', environment: 'master', locale: 'es-AR', json_template: json_path, mark_processed: false, trigger_oauth: false, quiet: true)

        subject.run
      }

      vcr('check_update_space_localized') {
        client = Contentful::Client.new(
          space: 'vsy1ouf6jdcq',
          access_token: '90e1b4964c3631cc9c751c42339814635623b001a53aec5aad23377299445433',
          dynamic_entries: :auto,
          raise_errors: true
        )

        entries = client.entries(locale: 'es-AR')

        expect(entries.map(&:text)).to eq ['Foo', 'Bar']
      }
    end

    it 'can update an existing asset and keep it as draft' do
      vcr('update_existing_asset') {
        json_path = File.expand_path(File.join('spec', 'fixtures', 'json_fixtures', 'assets_draft.json'))
        subject = described_class.new(token, 'f3abi4dqvrhg', environment: 'master', json_template: json_path, no_publish: true, trigger_oauth: false, quiet: true)

        subject.run
      }

      vcr('check_update_space_with_draft_content') {
        delivery_client = Contentful::Client.new(
          space: 'f3abi4dqvrhg',
          access_token: 'efab52abe735b200abb0f053ad8a3d0da633487c0c98cf03dc806c2b3bd049a1',
          dynamic_entries: :auto,
          raise_errors: true
        )

        preview_client = Contentful::Client.new(
          space: 'f3abi4dqvrhg',
          access_token: '06c28ef41823bb636714dfd812066fa026a49e95041a0e94903d6cf016bba50e',
          dynamic_entries: :auto,
          api_url: 'preview.contentful.com',
          raise_errors: true
        )

        delivery_cat = delivery_client.assets.first
        preview_cat = preview_client.assets.first

        expect(preview_cat.title).not_to eq delivery_cat
        expect(preview_cat.title).to eq 'Cat'
        expect(delivery_cat.title).to eq 'Foo'
      }
    end

    it 'can update a specific environment different than master' do
      delivery_client = nil
      vcr('check_original_staging_environment_status') {
        delivery_client = Contentful::Client.new(
          space: '9utsm1g0t7f5',
          access_token: 'a67d4d9011f6d6c1dfe4169d838114d3d3849ab6df6fb1d322cf3ee91690fae4',
          environment: 'staging',
          dynamic_entries: :auto,
          raise_errors: true
        )

        expect(delivery_client.entries.size).to eq 1
      }

      vcr('update_with_environment') {
        json_path = File.expand_path(File.join('spec', 'fixtures', 'json_fixtures', 'environment_template.json'))
        subject = described_class.new(token, '9utsm1g0t7f5', environment: 'staging', json_template: json_path, trigger_oauth: false, quiet: true)

        subject.run
      }

      vcr('check_staging_environment_status') {
        entries = delivery_client.entries
        expect(entries.size).to eq 2
        expect(entries.items.detect { |i| i.id == 'foo_update' }.name).to eq 'Test updated'
      }
    end
  end
end
