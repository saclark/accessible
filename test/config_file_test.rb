require_relative 'test_helper'

class ConfigFileTest < Minitest::Spec
  describe Accessible::ConfigFile do
    before do
      @file = Accessible::ConfigFile.new('config/sample.yml')
    end

    describe '#file' do
      it 'should return the file path passed to the contructor' do
        @file.file.must_equal('config/sample.yml')
      end
    end

    describe '#read' do
      it 'should return the file contents as a string' do
        @file.read.must_equal("numbers:\n  integers:\n    :one: <%= 1 / 1 %>\n")
      end
    end

    describe '#evaluate' do
      it 'should return file contents as an erb evaluated string' do
        @file.evaluate.must_equal("numbers:\n  integers:\n    :one: 1\n")
      end
    end

    describe '#load' do
      it 'should return the file contents as a hash' do
        @file.load.must_be_instance_of(Hash)
      end

      it 'should return file data as a hash with keys unaltered' do
        @file.load['numbers']['integers'][:one].wont_be_nil
      end

      it 'should return an empty hash if the file is empty' do
        Accessible::ConfigFile.new('config/empty.yml').load.must_equal({})
      end
    end
  end
end
