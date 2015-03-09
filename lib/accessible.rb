require 'accessible/accessorizers'
require 'accessible/data_loader'
require 'accessible/hash_methods'
require 'accessible/version'

module Accessible
  def self.included(base)
    base.extend(ClassMethods)
  end

  module ClassMethods
    def to_h
      @data ||= {}
    end

    def load(source, namespace = nil)
      to_h.clear
      merge(source, namespace)
    end

    def merge(source, namespace = nil)
      new_data = DataLoader.load_source(source)

      if namespace
        @data = HashMethods.deep_merge(to_h, new_data.fetch(namespace))
      else
        @data = HashMethods.deep_merge(to_h, new_data)
      end

      Accessorizers.accessorize_obj(self)
      Accessorizers.accessorize_data(to_h)

      to_h
    end

    def [](key)
      to_h[key]
    end

    def []=(key, new_value)
      Accessorizers.define_accessors(to_h, key)
      Accessorizers.define_accessors(self, key)
      to_h[key] = Accessorizers.accessorize_data(new_value)
    end
  end
end
