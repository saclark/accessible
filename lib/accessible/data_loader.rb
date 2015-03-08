require 'yaml'
require 'erb'

module Accessible
  module DataLoader
    extend self

    def evaluate_erb(text)
      ERB.new(text).result
    end

    def load_yaml_erb(yaml_file)
      contents = File.read(yaml_file)
      evaluated_contents = evaluate_erb(contents)
      YAML.load(evaluated_contents) || {}
    end

    def load_source(source)
      case source
      when Hash
        source
      when Symbol
        load_yaml_erb("config/#{source}.yml")
      when String
        load_yaml_erb(source)
      else
        raise("Invalid data source '#{source}'")
      end
    end
  end
end
