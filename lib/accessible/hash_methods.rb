module Accessible
  module HashMethods
    extend self

    def each_hash(data, &block)
      case data
      when Hash
        block.call(data)
      when Array
        data.each { |elem| each_hash(elem, &block) }
      end

      data
    end

    def deep_merge(orig_data, new_data)
      merger = proc do |key, v1, v2|
        Hash === v1 && Hash === v2 ? v1.merge(v2, &merger) : v2
      end

      orig_data.merge(new_data, &merger)
    end
  end
end
