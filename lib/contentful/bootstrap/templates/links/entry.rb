require "contentful/bootstrap/templates/links/base"

module Contentful
  module Bootstrap
    module Templates
      module Links
        class Entry < Base
          def kind
            :entries
          end
        end
      end
    end
  end
end
