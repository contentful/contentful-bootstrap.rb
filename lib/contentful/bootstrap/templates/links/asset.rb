require 'contentful/management'
require 'contentful/bootstrap/templates/links/base'

module Contentful
  module Bootstrap
    module Templates
      module Links
        class Asset < Base
          def management_class
            Contentful::Management::Asset
          end
        end
      end
    end
  end
end
