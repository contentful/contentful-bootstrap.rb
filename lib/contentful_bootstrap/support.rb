require "stringio"

module ContentfulBootstrap
  module Support
    def silence_stderr
      old_stderr, $stderr = $stderr, StringIO.new
      yield
    ensure
      $stderr = old_stderr
    end
  end
end
