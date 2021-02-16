module Tori
  module Backend
    class FileSystem
      ResourceError = Class.new(StandardError)

      attr_accessor :root
      def initialize(root)
        @root = root
        FileUtils.mkdir_p @root.to_s
      end

      def write(filename, resource, opts = nil)
        pathname = path(filename)
        FileUtils.mkdir_p pathname.dirname

        if resource.nil? && opts && opts[:body]
          resource = opts[:body]
        end

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
        when NilClass
          raise ResourceError, "null resource"
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

      def read(filename, *arg, **opt)
        open(filename, **{mode: 'rb'}.merge(opt)) do |f|
          f.read(*arg)
        end
      end

      def open(filename, *arg, **key, &block)
        ::File.open(path(filename), *arg, **key, &block)
      end

      def copy_to(filename, tori_file, **opts)
        FileUtils.mkdir_p tori_file.path.dirname

        ::File.open(path(filename)) do |from|
          ::File.open(tori_file.path, 'w+') do |to|
            IO.copy_stream(from, to)
          end
        end
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
