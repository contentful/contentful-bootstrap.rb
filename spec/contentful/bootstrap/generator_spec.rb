require 'spec_helper'

describe Contentful::Bootstrap::Generator do
  subject { described_class.new('wl1z0pal05vy', '48d7db7d4cd9d09df573c251d456f4acc72141b92f36e57f8684b36cf5cfff6e', 'master', false, false, []) }

  describe 'user agent headers' do
    it 'client has proper integration data' do
      expect(subject.client.app_info).to eq(name: 'bootstrap', version: Contentful::Bootstrap::VERSION)
    end
  end

  describe 'JSON template generator' do
    it 'can generate a JSON template for a given space' do
      vcr('generate_json') {
        json_fixture('wl1z0pal05vy') { |json|
          expect(subject.generate_json).to eq JSON.pretty_generate(json)
        }
      }
    end

    context 'with content_types_only set to true' do
      subject { described_class.new('wl1z0pal05vy', '48d7db7d4cd9d09df573c251d456f4acc72141b92f36e57f8684b36cf5cfff6e', 'master', true, false, []) }

      it 'can generate a JSON template for a given space with only Content Types' do
        vcr('generate_json_content_types_only') {
          json_fixture('wl1z0pal05vy_content_types_only') { |json|
            expect(subject.generate_json).to eq JSON.pretty_generate(json)
          }
        }
      end
    end
  end
end
