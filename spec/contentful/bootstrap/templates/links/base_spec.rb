require 'spec_helper'

describe Contentful::Bootstrap::Templates::Links::Base do
  subject { described_class.new 'foo' }

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

      describe '#==' do
        it 'false when different type' do
          expect(subject == 2).to be_falsey
        end

        it 'false when different id' do
          expect(subject == described_class.new('bar')).to be_falsey
        end

        it 'true when same id' do
          expect(subject == described_class.new('foo')).to be_truthy
        end
      end
    end
  end

  describe 'properties' do
    it ':id' do
      expect(subject.id).to eq 'foo'
    end
  end
end
