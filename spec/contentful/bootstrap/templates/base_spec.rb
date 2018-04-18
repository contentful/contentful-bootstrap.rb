require 'spec_helper'

describe Contentful::Bootstrap::Templates::Base do
  let(:space) { Contentful::Management::Space.new }
  subject { described_class.new(space, 'master', true) }

  before :each do
    environment_proxy = Object.new
    allow(space).to receive(:environments) { environment_proxy }

    environment = Object.new
    allow(environment_proxy).to receive(:find) { environment }
  end

  describe 'instance methods' do
    it '#content_types' do
      expect(subject.content_types).to eq []
    end

    it '#entries' do
      expect(subject.entries).to eq({})
    end

    it '#assets' do
      expect(subject.assets).to eq []
    end

    describe '#run' do
      it 'calls create for each kind of object' do
        ['content_types', 'assets', 'entries'].each do |name|
          expect(subject).to receive("create_#{name}".to_sym)
        end

        subject.run
      end

      it 'calls after_run when done' do
        expect(subject).to receive(:after_run)

        subject.run
      end

      context 'with skip_content_types set to true' do
        subject { described_class.new(space, 'master', true, true) }

        it 'doesnt call create_content_type if skip_content_types is sent' do
          expect(subject).to receive(:create_entries)
          expect(subject).to receive(:create_assets)
          expect(subject).not_to receive(:create_content_types)

          subject.run
        end
      end
    end
  end
end
