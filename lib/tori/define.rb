module Tori
  module Define
    def tori(name)
      name_file_ivar = "@#{name}_file".to_sym

      define_method(name) do
        ivar = instance_variable_get name_file_ivar
        instance_variable_set name_file_ivar, ivar || File.new(self)
      end

      define_method("#{name}=") do |uploader|
        file = File.new(self, uploader)
        instance_variable_set name_file_ivar, file
      end
    end
  end
end
