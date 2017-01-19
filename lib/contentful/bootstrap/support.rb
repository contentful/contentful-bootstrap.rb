require 'stringio'

module Contentful
  module Bootstrap
    module Support
      def self.silence_stderr
        old_stderr = $stderr
        $stderr = StringIO.new
        yield
      ensure
        $stderr = old_stderr
      end

      def self.output(text = nil, quiet = false)
        if text.nil?
          puts unless quiet
          return
        end

        puts text unless quiet
      end
    end
  end
end
