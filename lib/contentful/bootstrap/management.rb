require 'contentful/management'

module Contentful
  module Bootstrap
    class Management < ::Contentful::Management::Client
      def user_agent
        Hash['User-Agent', "ContentfulBootstrap/#{Contentful::Bootstrap::VERSION}"]
      end
    end
  end
end
