require 'contentful/management'
require 'contentful/bootstrap/templates/links/base'

module Contentful
  module Bootstrap
    module Templates
      module Links
        class Entry < Base
          def management_class
            Contentful::Management::Entry
          end
        end
      end
    end
  end
end
