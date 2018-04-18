require 'contentful/management'

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
            self.class.name.split('::').last
          end

          def type
            Contentful::Management::ContentType::LINK
          end

          def to_management_object
            object = management_class.new
            object.id = id
            object
          end

          def management_class
            raise 'must implement'
          end

          def ==(other)
            return false unless other.is_a? self.class
            other.id == id
          end
        end
      end
    end
  end
end
