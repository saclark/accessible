module Accessible
  module Accessorizers
    extend self

    def accessorize_data(data)
      HashMethods.each_hash(data) do |hash|
        hash.each do |key, value|
          define_accessors(hash, key)
          accessorize_data(value)
        end
      end
    end

    def accessorize_obj(obj)
      if !obj.respond_to?(:to_h)
        raise(NotImplementedError, "Expected `#{obj}` to respond to `:to_h`")
      end

      obj.to_h.keys.each do |key|
        define_accessors(obj, key)
      end
    end

    def define_accessors(obj, key)
      define_getter(obj, key)
      define_setter(obj, key)
    end

    def define_getter(obj, key)
      obj.define_singleton_method(key) do
        obj.to_h.fetch(key)
      end
    end

    def define_setter(obj, key)
      obj.define_singleton_method("#{key}=") do |new_value|
        obj.to_h[key] = Accessible::Accessorizers.accessorize_data(new_value)
      end
    end
  end
end
