module Contentful
  module Bootstrap
    VERSION = '3.0.0'

    def self.major_version
      VERSION.split('.').first.to_i
    end
  end
end
