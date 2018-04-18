require 'spec_helper'

describe Contentful::Bootstrap::Templates::Blog do
  let(:space) { Contentful::Management::Space.new }
  subject { described_class.new(space, 'master') }

  before :each do
    environment_proxy = Object.new
    allow(space).to receive(:environments) { environment_proxy }

    environment = Object.new
    allow(environment_proxy).to receive(:find) { environment }
  end

  describe 'content types' do
    it 'has Post content type' do
      expect(subject.content_types.detect { |ct| ct['id'] == 'post' }).to be_truthy
    end

    it 'has Author content type' do
      expect(subject.content_types.detect { |ct| ct['id'] == 'author' }).to be_truthy
    end
  end

  describe 'entries' do
    it 'has 2 posts' do
      expect(subject.entries['post'].size).to eq 2
    end

    it 'has 2 authors' do
      expect(subject.entries['author'].size).to eq 2
    end
  end

  describe 'assets' do
    it 'has no assets' do
      expect(subject.assets.empty?).to be_truthy
    end
  end
end
