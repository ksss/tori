module Tori
  module Backend
    class FileSystem
      def initialize(root)
        @root = root
        FileUtils.mkdir_p(@root.to_s)
      end

      def copy(form_path, to_filename)
        IO.copy_stream(form_path, @root.join(to_filename))
      end

      def delete(filename)
        File.unlink @root.join(filename)
      end
    end
  end
end
