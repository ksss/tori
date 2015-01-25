module Tori
  module Define
    def tori(name)
      name_filename_get = "#{name}_filename".to_sym
      name_ivar = "@#{name}".to_sym
      name_filename_ivar = "@#{name}_filename".to_sym

      define_method(name) do
        instance_variable_get name_ivar
      end

      define_method("#{name}=") do |uploader|
        instance_variable_set name_ivar, uploader
      end

      define_method(name_filename_get) do
        Tori.config.filename_callback.call(self)
      end
    end
  end
end
