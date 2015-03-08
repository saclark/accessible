require 'accessible/version'
require 'accessible/config_file'
require 'accessible/hash_accessors'

module Accessible
  def self.included(base)
    base.extend(ClassMethods)
  end

  module ClassMethods
    def to_h
      @data ||= {}
    end

    def base(source, namespace = nil)
      to_h.clear
      merge!(source, namespace)
    end

    def merge!(source, namespace = nil)
      new_data = load(source)

      if namespace
        @data = deep_merge(to_h, new_data.fetch(namespace))
      else
        @data = deep_merge(to_h, new_data)
      end

      accessorize_self!
      HashAccessors.accessorize(to_h)

      to_h
    end

    def accessorize_self!
      to_h.keys.each do |key|
        define_singleton_method(key) { to_h.fetch(key) }
        define_singleton_method("#{key}=") do |value|
          to_h[key] = Accessible::HashAccessors.accessorize(value)
        end
      end
    end

    def load(source)
      case source
      when Hash
        source
      when Symbol
        ConfigFile.new("config/#{source}.yml").load
      when String
        ConfigFile.new(source).load
      else
        raise("Invalid Accessible data source '#{source}'")
      end
    end

    def deep_merge(orig_data, new_data)
      merger = proc do |key, v1, v2|
        Hash === v1 && Hash === v2 ? v1.merge(v2, &merger) : v2
      end

      orig_data.merge(new_data, &merger)
    end

    def symbolize_keys(data)
      if data.is_a?(Hash)
        return data.inject({}) do |new_hash, (k, v)|
          new_hash.merge!(k.to_sym => symbolize_keys(v))
        end
      end

      if data.is_a?(Array)
        return data.inject([]) do |new_array, v|
          new_array.push(symbolize_keys(v))
        end
      end

      data
    end
  end
end
