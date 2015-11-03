require "contentful/bootstrap/templates/links/base"

module Contentful
  module Bootstrap
    module Templates
      module Links
        class Asset < Base
          def kind
            :assets
          end
        end
      end
    end
  end
end
