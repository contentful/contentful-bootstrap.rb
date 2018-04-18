require 'spec_helper'

describe Contentful::Bootstrap::Commands::GenerateJson do
  subject { described_class.new('foo', 'bar') }

  describe 'instance methods' do
    describe '#run' do
      it 'exits if access_token is nil' do
        subject.instance_variable_set(:@access_token, nil)
        subject.instance_variable_set(:@quiet, true)

        expect { subject.run }.to raise_error SystemExit
      end

      it 'calls generator' do
        allow(subject).to receive(:write).with('json')

        expect_any_instance_of(Contentful::Bootstrap::Generator).to receive(:generate_json) { 'json' }

        subject.run
      end

      it 'writes json' do
        vcr('generate_json') {
          subject.instance_variable_set(:@space_id, 'wl1z0pal05vy')
          subject.instance_variable_set(:@access_token, '48d7db7d4cd9d09df573c251d456f4acc72141b92f36e57f8684b36cf5cfff6e')
          subject.instance_variable_set(:@quiet, true)

          json_fixture('wl1z0pal05vy') { |json|
            expect(subject).to receive(:write).with(JSON.pretty_generate(json))
          }

          subject.run
        }
      end

      it 'can use the preview api' do
        vcr('generate_json_preview') {
          subject.instance_variable_set(:@space_id, 'f3abi4dqvrhg')
          subject.instance_variable_set(:@access_token, '06c28ef41823bb636714dfd812066fa026a49e95041a0e94903d6cf016bba50e')
          subject.instance_variable_set(:@use_preview, true)
          subject.instance_variable_set(:@quiet, true)

          json_fixture('f3abi4dqvrhg_preview') { |json|
            expect(subject).to receive(:write).with(JSON.pretty_generate(json))
          }

          subject.run
        }
      end

      describe 'specific content types' do
        it 'can select a single content type' do
          vcr('generate_json_single_ct') {
            subject.instance_variable_set(:@space_id, 'cfexampleapi')
            subject.instance_variable_set(:@access_token, 'b4c0n73n7fu1')
            subject.instance_variable_set(:@content_type_ids, ['cat'])
            subject.instance_variable_set(:@quiet, true)

            json_fixture('cfexampleapi_cat') { |json|
              expect(subject).to receive(:write).with(JSON.pretty_generate(json))
            }

            subject.run
          }
        end

        it 'can select multiple content types' do
          vcr('generate_json_multi_ct') {
            subject.instance_variable_set(:@space_id, 'cfexampleapi')
            subject.instance_variable_set(:@access_token, 'b4c0n73n7fu1')
            subject.instance_variable_set(:@content_type_ids, ['cat', 'human'])
            subject.instance_variable_set(:@quiet, true)

            json_fixture('cfexampleapi_cat_human') { |json|
              expect(subject).to receive(:write).with(JSON.pretty_generate(json))
            }

            subject.run
          }
        end
      end
    end

    describe '#write' do
      it 'outputs json to stoud if no filename provided' do
        expect { subject.write('json') }.to output("json\n").to_stdout
      end

      it 'writes to file if filename provided' do
        subject.instance_variable_set(:@filename, 'foo')

        expect(::File).to receive(:write).with('foo', 'json')

        expect { subject.write('json') }.to output("Saving JSON template to 'foo'\n").to_stdout
      end
    end
  end

  describe 'attributes' do
    it ':space_id' do
      expect(subject.space_id).to eq 'foo'
    end

    it ':access_token' do
      expect(subject.access_token).to eq 'bar'
    end

    it ':filename' do
      expect(subject.filename).to eq nil
    end
  end
end
