module Contentful
  module Bootstrap
    VERSION = '3.12.0'.freeze

    def self.major_version
      VERSION.split('.').first.to_i
    end
  end
end
