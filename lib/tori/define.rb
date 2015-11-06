module Tori
  module Define
    def tori(name, to: nil, &block)
      name_ivar = "@#{name}".to_sym

      define_method(name) do
        ivar = instance_variable_get name_ivar
        ivar || instance_variable_set(name_ivar, File.new(self, title: name, to: to, &block))
      end

      define_method("#{name}=") do |uploader|
        file = File.new(self, title: name, from: uploader, to: to, &block)
        instance_variable_set name_ivar, file
      end
    end
  end
end
