require 'spec_helper'

describe Contentful::Bootstrap::Templates::Gallery do
  let(:space) { Contentful::Management::Space.new }
  subject { Contentful::Bootstrap::Templates::Gallery.new(space) }

  describe 'content types' do
    it 'has Author content type' do
      expect(subject.content_types.detect { |ct| ct['id'] == 'author' }).to be_truthy
    end

    it 'has Image content type' do
      expect(subject.content_types.detect { |ct| ct['id'] == 'image' }).to be_truthy
    end

    it 'has Gallery content type' do
      expect(subject.content_types.detect { |ct| ct['id'] == 'gallery' }).to be_truthy
    end
  end

  describe 'entries' do
    it 'has 1 author' do
      expect(subject.entries['author'].size).to eq 1
    end

    it 'has 2 images' do
      expect(subject.entries['image'].size).to eq 2
    end

    it 'has 1 gallery' do
      expect(subject.entries['gallery'].size).to eq 1
    end
  end

  describe 'assets' do
    it 'has 2 assets' do
      expect(subject.assets.size).to eq 2
    end
  end
end
