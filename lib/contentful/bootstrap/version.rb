module Contentful
  module Bootstrap
    VERSION = '3.1.0'

    def self.major_version
      VERSION.split('.').first.to_i
    end
  end
end
