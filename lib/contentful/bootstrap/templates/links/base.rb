module Contentful
  module Bootstrap
    module Templates
      module Links
        class Base
          attr_reader :id
          def initialize(id)
            @id = id
          end

          def kind
            raise "must implement"
          end
        end
      end
    end
  end
end
