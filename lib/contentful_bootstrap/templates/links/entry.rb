require "contentful_bootstrap/templates/links/base"

module ContentfulBootstrap
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
