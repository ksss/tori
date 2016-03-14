module Tori
  module Backend
    class FileSystem
      attr_accessor :root
      def initialize(root)
        @root = root
        FileUtils.mkdir_p @root.to_s
      end

      def write(filename, resource, opts = nil)
        pathname = path(filename)
        FileUtils.mkdir_p pathname.dirname

        case resource
        when String
          ::File.open(pathname, 'wb'){ |f| f.write resource }
        when Pathname
          # see also https://bugs.ruby-lang.org/issues/11199
          ::File.open(resource) { |src|
            ::File.open(pathname, 'wb'){ |dst|
              ::IO.copy_stream src, dst
            }
          }
        else
          ::File.open(pathname, 'wb') do |dst|
            ::IO.copy_stream resource, dst
          end
        end
      end

      def delete(filename)
        ::File.unlink path(filename)
      end

      def exist?(filename)
        ::File.exist? path(filename)
      end
      alias exists? exist?

      def read(filename, **args)
        ::File.read(path(filename), { mode: 'rb' }.merge(args))
      end

      def open(filename, *rest, &block)
        ::File.open(path(filename), *rest, &block)
      end

      def path(filename)
        @root.join filename.to_s
      end

      def otherwise(backend)
        Chain.new(self, backend)
      end
    end
  end
end
