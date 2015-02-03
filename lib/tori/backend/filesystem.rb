module Tori
  module Backend
    class FileSystem
      attr_accessor :root
      def initialize(root)
        @root = root
        FileUtils.mkdir_p @root.to_s
      end

      def copy(form_path, to_filename)
        IO.copy_stream form_path.to_s, path(to_filename)
      end

      def delete(filename)
        ::File.unlink path(filename)
      end

      def exist?(filename)
        ::File.exist? path(filename)
      end
      alias exists? exist?

      def read(filename)
        ::File.read path(filename)
      end

      private
      def path(filename)
        @root.join filename.to_s
      end
    end
  end
end
