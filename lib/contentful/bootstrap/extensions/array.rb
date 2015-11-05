require "contentful/management"

module Contentful
  module Bootstrap
    module Extensions
      module Array
        def type
          Contentful::Management::ContentType::ARRAY
        end
      end
    end
  end
end
