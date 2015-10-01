require 'accessible/accessorizers'
require 'accessible/data_loader'
require 'accessible/hash_methods'
require 'accessible/version'

module Accessible
  def self.included(base)
    base.extend(ClassMethods)
  end

  def self.create
    klass = Class.new { extend ClassMethods }
    yield klass if block_given?
    klass
  end

  module ClassMethods
    def to_h
      @data ||= {}
    end

    def load(data_source, namespace = nil)
      to_h.clear
      merge(data_source, namespace)
    end

    def merge(data_source, namespace = nil)
      source_data = DataLoader.load_source(data_source)
      new_data = namespace ? source_data.fetch(namespace) : source_data

      @data = HashMethods.deep_merge(to_h, new_data)

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
