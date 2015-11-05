require "contentful/management"

module Contentful
  module Bootstrap
    module Templates
      module Links
        class Base
          attr_reader :id
          def initialize(id)
            @id = id
          end

          def link_type
            self.class.name
          end

          def kind
            raise "must implement"
          end

          def type
            Contentful::Management::ContentType::LINK
          end
        end
      end
    end
  end
end
