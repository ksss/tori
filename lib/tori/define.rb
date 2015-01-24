module Tori
  module Define
    def tori(name, id: :id)
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
        Tori.config.hash_method.call "#{self.class.name}/#{__send__(id.to_sym)}"
      end
    end
  end
end
