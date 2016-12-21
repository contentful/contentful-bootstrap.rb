require 'spec_helper'

describe Contentful::Bootstrap::Token do
  let(:path) { File.expand_path(File.join('spec', 'fixtures', 'ini_fixtures', 'contentfulrc.ini')) }
  let(:no_token_path) { File.expand_path(File.join('spec', 'fixtures', 'ini_fixtures', 'no_token.ini')) }
  let(:sections_path) { File.expand_path(File.join('spec', 'fixtures', 'ini_fixtures', 'sections.ini')) }
  let(:no_global_path) { File.expand_path(File.join('spec', 'fixtures', 'ini_fixtures', 'no_global.ini')) }
  let(:with_org_id) { File.expand_path(File.join('spec', 'fixtures', 'ini_fixtures', 'orgid.ini')) }
  subject { Contentful::Bootstrap::Token.new(path) }

  describe 'attributes' do
    it ':config_path' do
      expect(subject.config_path).to eq path
    end
  end

  describe 'initialize' do
    it 'uses provided config_path' do
      expect(subject.class.new('bar').config_path).to eq 'bar'
    end
  end

  describe 'instance methods' do
    describe '#present?' do
      it 'non existing file returns false' do
        expect(subject.class.new('foobar').present?).to be_falsey
      end

      it 'existing file without management token returns false' do
        expect(subject.class.new(no_token_path).present?).to be_falsey
      end

      it 'existing file with management token returns true' do
        expect(subject.present?).to be_truthy
      end
    end

    describe '#filename' do
      it 'returns default path if config_path is empty' do
        expect(subject.class.new.filename).to eq ::File.join(ENV['HOME'], subject.class::DEFAULT_PATH)
      end

      it 'returns config_path' do
        expect(subject.filename).to eq path
      end
    end

    describe '#config_section' do
      it 'returns default section by default' do
        expect(subject.config_section).to eq 'global'
      end

      it 'returns default section if ENV["CONTENTFUL_ENV"] section does not exist' do
        ENV['CONTENTFUL_ENV'] = 'blah'
        expect(subject.class.new(sections_path).config_section).to eq 'global'
        ENV['CONTENTFUL_ENV'] = ''
      end

      it 'returns ENV["CONTENTFUL_ENV"] section if exists' do
        ENV['CONTENTFUL_ENV'] = 'other_section'
        expect(subject.class.new(sections_path).config_section).to eq 'other_section'
        ENV['CONTENTFUL_ENV'] = ''
      end
    end

    describe '#read' do
      it 'fails if "global" section does not exist' do
        expect { subject.class.new(no_global_path).read }.to raise_error 'Token not found'
      end

      it 'fails if management token is not found' do
        expect { subject.class.new(no_token_path).read }.to raise_error 'Token not found'
      end

      it 'returns token if its found' do
        expect(subject.read).to eq 'foobar'
      end
    end

    describe '#read_organization_id' do
      it 'nil if default org id is not set' do
        expect(subject.read_organization_id).to be_nil
      end

      it 'returns value of org id is set' do
        expect(subject.class.new(with_org_id).read_organization_id).to eq 'my_org'
      end
    end

    describe 'write methods' do
      before do
        @file = subject.config_file
        expect(@file).to receive(:save)
      end

      it '#write_access_token' do

        expect(@file.has_section?('some_space')).to be_falsey

        subject.write_access_token('some_space', 'asd')

        expect(@file['some_space']['CONTENTFUL_DELIVERY_ACCESS_TOKEN']).to eq 'asd'
      end

      it '#write_space_id' do
        expect(@file.has_section?('some_space')).to be_falsey

        subject.write_space_id('some_space', 'asd')

        expect(@file['some_space']['SPACE_ID']).to eq 'asd'
      end

      it '#write_organization_id' do
        subject.write_organization_id('foo')
        expect(@file['global']['CONTENTFUL_ORGANIZATION_ID']).to eq 'foo'
      end

      describe '#write' do
        it 'writes management tokens when only value is sent' do
          expect(@file['global']['CONTENTFUL_MANAGEMENT_ACCESS_TOKEN']).to eq 'foobar'

          subject.write('baz')

          expect(@file['global']['CONTENTFUL_MANAGEMENT_ACCESS_TOKEN']).to eq 'baz'
        end

        it 'can write management tokens to any section' do
          expect(@file.has_section?('blah')).to be_falsey

          subject.write('baz', 'blah')

          expect(@file['blah']['CONTENTFUL_MANAGEMENT_ACCESS_TOKEN']).to eq 'baz'
        end

        it 'can write any key to any section' do
          expect(@file.has_section?('blah')).to be_falsey

          subject.write('foo', 'bar', 'baz')

          expect(@file['bar']['baz']).to eq 'foo'
        end
      end
    end

    describe '#==' do
      it 'returns false when other is not a token' do
        expect(subject == 1).to be_falsey
      end

      it 'returns false when other token does not have same config_path' do
        expect(subject == subject.class.new('foo')).to be_falsey
      end

      it 'returns true when other token has same config_path' do
        expect(subject == subject.class.new(path)).to be_truthy
      end
    end
  end
end
