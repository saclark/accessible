module Accessible
  module HashAccessors
    extend self

    def accessorize(data)
      each_hash(data) do |hash|
        hash.each do |key, value|
          define_getter(hash, key)
          define_setter(hash, key)
          accessorize(value)
        end
      end
    end

    def each_hash(data, &block)
      case data
      when Hash
        block.call(data)
      when Array
        data.each { |elem| each_hash(elem, &block) }
      end

      data
    end

    def define_getter(data, key)
      data.define_singleton_method(key) do
        self.fetch(key)
      end
    end

    def define_setter(data, key)
      data.define_singleton_method("#{key}=") do |new_value|
        self[key] = Accessible::HashAccessors.accessorize(new_value)
      end
    end
  end
end
