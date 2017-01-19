require 'spec_helper'

class Double
  def write
    $stderr.write('foo\n')
  end

  def muted_write
    Contentful::Bootstrap::Support.silence_stderr do
      write
    end
  end
end

describe Contentful::Bootstrap::Support do
  subject { Double.new }

  describe 'module methods' do
    it '#silence_stderr' do
      expect { subject.write }.to output('foo\n').to_stderr

      expect { subject.muted_write }.to_not output.to_stderr
    end
  end
end
