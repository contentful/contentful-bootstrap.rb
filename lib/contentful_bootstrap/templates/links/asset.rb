require "contentful_bootstrap/templates/links/base"

module ContentfulBootstrap
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
