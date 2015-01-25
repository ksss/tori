module Tori
  module Backend
    class FileSystem
      attr_accessor :root
      def initialize(root)
        @root = root
        FileUtils.mkdir_p(@root.to_s)
      end

      def copy(form_path, to_filename)
        IO.copy_stream(form_path.to_s, @root.join(to_filename.to_s))
      end

      def delete(filename)
        ::File.unlink @root.join(filename.to_s)
      end

      def exist?(filename)
        ::File.exist? @root.join(filename.to_s)
      end

      def read(filename)
        ::File.read @root.join(filename.to_s)
      end
    end
  end
end
