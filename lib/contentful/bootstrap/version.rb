module Contentful
  module Bootstrap
    VERSION = '3.11.1'.freeze

    def self.major_version
      VERSION.split('.').first.to_i
    end
  end
end
