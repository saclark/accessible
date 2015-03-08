require 'yaml'
require 'erb'

module Accessible
  class ConfigFile
    attr_accessor :file

    def initialize(file)
      @file = file
    end

    def read
      File.read(@file)
    end

    def evaluate
      ERB.new(self.read).result
    end

    def load
      YAML.load(self.evaluate) || {}
    end
  end
end
