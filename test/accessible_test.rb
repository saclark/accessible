require_relative 'test_helper'

class AccessibleTest < Minitest::Spec
  describe Accessible do
    let(:config) { Class.new { include Accessible } }

    describe '#to_h' do
      it 'should create @data if it does not exist' do
        config.instance_variable_defined?(:@data).must_equal(false)
        config.to_h
        config.instance_variable_defined?(:@data).must_equal(true)
      end

      it 'should assign an empty hash to @data if it does not exist' do
        config.instance_variable_defined?(:@data).must_equal(false)
        config.to_h
        config.instance_variable_get(:@data).must_equal({})
      end

      it 'should return a Hash instance' do
        config.to_h.must_be_instance_of(Hash)
        config.base({ :adding => ['data'] })
        config.to_h.must_be_instance_of(Hash)
      end

      it 'should return @data' do
        config.to_h.must_equal(config.instance_variable_get(:@data))
      end
    end

    describe '#base' do
      it 'should reassign @data to the given data' do
        config.base({ :a => 'a' })
        config.to_h.must_equal({ :a => 'a' })
        config.base({ :b => 'b' })
        config.to_h.must_equal({ :b => 'b' })
      end

      it 'should assign all data if no namespace given' do
        config.base({ :a => 'a', :b => 'b' })
        config.to_h.must_equal({ :a => 'a', :b => 'b' })
      end

      it 'should assign namespaced data if namespace given' do
        config.base({ :a => 'a', :foo => { :b => 'b'} }, :foo)
        config.to_h.must_equal({ :b => 'b' })
      end

      it 'should raise a KeyError if the given namespace is not found' do
        proc do
          config.base({ :a => 'a', :foo => { :b => 'b'} }, :bar)
        end.must_raise(KeyError)
      end
    end

    describe '#merge!' do
      it 'should accept a hash and load it' do
        config.merge!({ :a => 'a' })
        config.to_h.must_equal({ :a => 'a' })
      end

      it 'should accept a symbol and load the corresponding config file' do
        config.merge!(:my_config)
        config.to_h.must_equal({ 'data' => 'data from config/my_config.yml' })
      end

      it 'should accept a file path and load the file' do
        config.merge!('config/more_configs/my_config.yaml')
        config.to_h.must_equal({ 'data' => 'data from config/more_configs/my_config.yaml' })
      end

      it 'should raise an error when not given a hash, symbol, or string' do
        begin
          config.merge!(100)
        rescue RuntimeError => e
          e.message.must_equal("Invalid Accessible data source '100'")
        end
      end

      it 'should not require a base source to have been set' do
        config.merge!({ :a => 'a' })
        config.to_h.must_equal({ :a => 'a' })
      end

      it 'should mutate @data' do
        config.base({ :foo => 'original' })
        config.merge!({ :foo => 'new' })
        config.to_h.must_equal({ :foo => 'new' })
      end

      it 'should merge all data if no namespace given' do
        config.base({ :a => 'a'})
        config.merge!({ :a => 'a', :b => 'b' })
        config.to_h.must_equal({ :a => 'a', :b => 'b' })
      end

      it 'should merge namespaced data if namespace given' do
        config.base({ :a => 'a' })
        config.merge!({ :foo => { :a => 'new a' }, :b => 'b' }, :foo)
        config.to_h.must_equal({ :a => 'new a' })
      end

      it 'should raise a KeyError if the given namespace is not found' do
        proc do
          config.merge!({ :a => 'a', :foo => { :b => 'b'} }, :bar)
        end.must_raise(KeyError)
      end

      it 'should perform a deep merge' do
        h1 = { :a => true, :b => { :c => [1, 2, 3] } }
        h2 = { :a => false, :b => { :x => [3, 4, 5] } }

        config.base(h1)
        config.merge!(h2)
        config.to_h.must_equal({
          :a => false,
          :b => {
            :c => [1, 2, 3],
            :x => [3, 4, 5]
          }
        })
      end

      it 'should define acessors on @data' do
        config.merge!({ :a => 'a' })
        config.to_h.singleton_methods.must_include(:a)
        config.to_h.singleton_methods.must_include(:a=)
      end

      it 'should define accessors on the instance' do
        config.merge!({ :a => 'a' })
        config.singleton_methods.must_include(:a)
        config.singleton_methods.must_include(:a=)
      end

      it 'should return a Hash instance' do
        config.merge!({}).must_be_instance_of(Hash)
      end

      it 'should return the result of calling #to_h after the merge' do
        config.base({ :a => 'a' })
        merge_result = config.merge!({ :b => 'b' })
        merge_result.must_equal(config.to_h)
      end
    end

    describe '#accessorize_self!' do
      it 'should define getters on the class for all first tier keys' do
        config.base({ :a => { :b => 'b' }, :c => 'c' })
        config.accessorize_self!
        config.a.must_equal({ :b => 'b' })
        config.c.must_equal('c')
        config.wont_respond_to(:b)
      end

      it 'should define getters equivalent to calling :fetch on @data with the same key' do
        config.base({ :foo => 'foo value'})
        config.accessorize_self!
        (config.to_h.fetch(:foo)).must_equal(config.foo)

        config.to_h.delete(:foo)
        proc { config.foo }.must_raise(KeyError)
      end

      it 'should define setters on the class for all first tier keys' do
        config.base({ :a => { :b => 'b' }, :c => 'c' })
        config.accessorize_self!

        config.a = 'new a value'
        config.a.must_equal('new a value')

        config.c = 'new c value'
        config.c.must_equal('new c value')

        config.wont_respond_to(:b=)
      end

      it 'should define accessors on set values' do
        config.base({ :foo => 'foo value' })
        config.accessorize_self!
        config.foo = { :new_value => 'new value' }

        config.to_h[:foo].must_respond_to(:new_value)
        config.to_h[:foo].must_respond_to(:new_value=)
      end

      it 'should be the same as calling :[]= with the same key and value' do
        config.base({ :foo => 'foo value' })
        config.accessorize_self!

        (config.foo = 'new foo value').must_equal(config.to_h[:foo] = 'new foo value')

        config.to_h.delete(:foo)
        config.foo = 'restored foo'
        config.foo.must_equal('restored foo')
      end
    end

    describe '#load' do
      it 'should accept a hash and return it' do
        data = config.load({ :a => 'a' })
        data.must_equal({ :a => 'a' })
      end

      it 'should accept a symbol and return the corresponding config file data' do
        data = config.load(:my_config)
        data.must_equal({ 'data' => 'data from config/my_config.yml' })
      end

      it 'should accept a file path and return the file data' do
        data = config.load('config/more_configs/my_config.yaml')
        data.must_equal({ 'data' => 'data from config/more_configs/my_config.yaml' })
      end

      it 'should raise an error when not given a hash, symbol, or string' do
        begin
          config.load(100)
        rescue RuntimeError => e
          e.message.must_equal("Invalid Accessible data source '100'")
        end
      end
    end

    describe '#deep_merge' do
      it 'should merge neseted hashes' do
        hash_1 = { :a => false, :b => "b", :c => { :c1 => "c1", :c2 => "c2", :c3 => { :d1 => "d1" } } }
        hash_2 = { :a => 1, :c => { :c1 => 2, :c3 => { :d2 => "d2" } } }
        expected = { :a => 1, :b => "b", :c => { :c1 => 2, :c2 => "c2", :c3 => { :d1 => "d1", :d2 => "d2" } } }

        config.deep_merge(hash_1, hash_2).must_equal(expected)
      end
    end
  end
end
