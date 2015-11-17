require 'spec_helper'

describe Contentful::Bootstrap::Generator do
  subject { Contentful::Bootstrap::Generator.new('wl1z0pal05vy', '48d7db7d4cd9d09df573c251d456f4acc72141b92f36e57f8684b36cf5cfff6e') }

  describe 'JSON template generator' do
    it 'can generate a JSON template for a given space' do
      vcr('generate_json') {
        json_fixture('wl1z0pal05vy') { |json|
          expect(subject.generate_json).to eq JSON.pretty_generate(json)
        }
      }
    end
  end
end
