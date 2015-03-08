require_relative 'test_helper'

class DataLoaderTest < Minitest::Spec
  describe Accessible::DataLoader do
    before do
      @file_path = 'config/sample.yml'
    end

    describe '#evaluate_erb' do
      it 'should return the erb evaluated string' do
        contents = File.read(@file_path)
        Accessible::DataLoader.evaluate_erb(contents).must_equal("numbers:\n  integers:\n    :one: 1\n")
      end
    end

    describe '#load_yaml_erb' do
      it 'should return the file contents as a hash' do
        Accessible::DataLoader.load_yaml_erb(@file_path).must_be_instance_of(Hash)
      end

      it 'should return file data as a hash with keys unaltered' do
        Accessible::DataLoader.load_yaml_erb(@file_path)['numbers']['integers'][:one].wont_be_nil
      end

      it 'should return an empty hash if the file is empty' do
        Accessible::DataLoader.load_yaml_erb('config/empty.yml').must_equal({})
      end
    end

    describe '#load_source' do
      it 'should accept a hash and return it' do
        data = Accessible::DataLoader.load_source({ :a => 'a' })
        data.must_equal({ :a => 'a' })
      end

      it 'should accept a symbol and return the corresponding file data' do
        data = Accessible::DataLoader.load_source(:my_config)
        data.must_equal({ 'data' => 'data from config/my_config.yml' })
      end

      it 'should accept a file path and return the file data' do
        data = Accessible::DataLoader.load_source('config/more_configs/my_config.yaml')
        data.must_equal({ 'data' => 'data from config/more_configs/my_config.yaml' })
      end

      it 'should raise an error when not given a hash, symbol, or string' do
        begin
          Accessible::DataLoader.load_source(100)
        rescue RuntimeError => e
          e.message.must_equal("Invalid data source '100'")
        end
      end
    end
  end
end
