require 'spec_helper'

describe Contentful::Bootstrap::Templates::Base do
  let(:space) { Contentful::Management::Space.new }
  subject { Contentful::Bootstrap::Templates::Base.new(space) }

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

    it '#run' do
      ['content_types', 'assets', 'entries'].each do |name|
        expect(subject).to receive("create_#{name}".to_sym)
      end

      subject.run
    end
  end

  describe 'attributes' do
    it ':space' do
      expect(subject.space).to eq space
    end
  end
end
