module Tori
  module Backend
    class FileSystem
      def initialize(root)
        @root = root
        FileUtils.mkdir_p(@root.to_s)
      end

      def copy(uploader, filename)
        IO.copy_stream(uploader, @root.join(filename))
      end

      def delete(filename)
        File.unlink @root.join(filename)
      end
    end
  end
end
