require 'spec_helper'

describe Contentful::Bootstrap::Templates::Links::Base do
  subject { Contentful::Bootstrap::Templates::Links::Base.new 'foo' }

  describe 'instance methods' do
    it '#link_type' do
      expect(subject.link_type).to eq 'Base'
    end

    it '#type' do
      expect(subject.type).to eq 'Link'
    end

    describe 'abstract methods' do
      it '#to_management_object' do
        expect { subject.to_management_object }.to raise_error "must implement"
      end

      it '#management_class' do
        expect { subject.management_class }.to raise_error "must implement"
      end
    end
  end

  describe 'properties' do
    it ':id' do
      expect(subject.id).to eq 'foo'
    end
  end
end
