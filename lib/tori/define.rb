module Tori
  module Define
    def tori(name)
      name_hash_get = "#{name}_hash".to_sym
      name_ivar = "@#{name}".to_sym
      name_hash_ivar = "@#{name}_hash".to_sym

      define_method(name) do
        instance_variable_get name_ivar
      end

      define_method("#{name}=") do |uploader|
        instance_variable_set name_ivar, uploader
      end

      define_method(name_hash_get) do
        Tori.config.hash_method.call(self)
      end
    end
  end
end
