require 'spec_helper'

describe Contentful::Bootstrap::Templates::Catalogue do
  let(:space) { Contentful::Management::Space.new }
  subject { described_class.new(space, 'master') }

  before :each do
    environment_proxy = Object.new
    allow(space).to receive(:environments) { environment_proxy }

    environment = Object.new
    allow(environment_proxy).to receive(:find) { environment }
  end

  describe 'content types' do
    it 'has Brand content type' do
      expect(subject.content_types.detect { |ct| ct['id'] == 'brand' }).to be_truthy
    end

    it 'has Category content type' do
      expect(subject.content_types.detect { |ct| ct['id'] == 'category' }).to be_truthy
    end

    it 'has Product content type' do
      expect(subject.content_types.detect { |ct| ct['id'] == 'product' }).to be_truthy
    end
  end

  describe 'entries' do
    it 'has 2 brands' do
      expect(subject.entries['brand'].size).to eq 2
    end

    it 'has 2 categories' do
      expect(subject.entries['category'].size).to eq 2
    end

    it 'has 2 products' do
      expect(subject.entries['product'].size).to eq 2
    end
  end

  describe 'assets' do
    it 'has 6 assets' do
      expect(subject.assets.size).to eq 6
    end
  end
end
