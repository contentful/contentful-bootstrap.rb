module Contentful
  module Bootstrap
    class Token
      def self.present?
        File.exist?(filename)
      end

      def self.read
        File.open(filename, "r") { |f|
          f.readlines[0]
        }
      end

      def self.write(token)
        File.open(filename, "w") { |f|
          f.write(token)
        }
      end

      def self.filename
        File.join(Dir.pwd, ".contentful_token")
      end
    end
  end
end
