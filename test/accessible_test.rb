require_relative 'test_helper'

class AccessibleTest < Minitest::Spec
  describe Accessible do
    let(:config) { Class.new { include Accessible } }

    describe '#to_h' do
      it 'should create `@data` if it does not exist' do
        config.instance_variable_defined?(:@data).must_equal(false)
        config.to_h
        config.instance_variable_defined?(:@data).must_equal(true)
      end

      it 'should assign an empty hash to `@data` if it does not exist' do
        config.instance_variable_defined?(:@data).must_equal(false)
        config.to_h
        config.instance_variable_get(:@data).must_equal({})
      end

      it 'should return a Hash instance' do
        config.to_h.must_be_instance_of(Hash)
        config.load({ :adding => ['data'] })
        config.to_h.must_be_instance_of(Hash)
      end

      it 'should return `@data`' do
        config.to_h.must_equal(config.instance_variable_get(:@data))
      end
    end

    describe '#load' do
      it 'should reassign `@data` to the given data' do
        config.load({ :a => 'a' })
        config.to_h.must_equal({ :a => 'a' })
        config.load({ :b => 'b' })
        config.to_h.must_equal({ :b => 'b' })
      end

      it 'should assign all data if no namespace given' do
        config.load({ :a => 'a', :b => 'b' })
        config.to_h.must_equal({ :a => 'a', :b => 'b' })
      end

      it 'should assign namespaced data if namespace given' do
        config.load({ :a => 'a', :foo => { :b => 'b'} }, :foo)
        config.to_h.must_equal({ :b => 'b' })
      end

      it 'should raise a KeyError if the given namespace is not found' do
        proc do
          config.load({ :a => 'a', :foo => { :b => 'b'} }, :bar)
        end.must_raise(KeyError)
      end
    end

    describe '#merge' do
      it 'should accept a hash and load it' do
        config.merge({ :a => 'a' })
        config.to_h.must_equal({ :a => 'a' })
      end

      it 'should accept a symbol and load the corresponding config file' do
        config.merge(:my_config)
        config.to_h.must_equal({ 'data' => 'data from config/my_config.yml' })
      end

      it 'should accept a file path and load the file' do
        config.merge('config/more_configs/my_config.yaml')
        config.to_h.must_equal({ 'data' => 'data from config/more_configs/my_config.yaml' })
      end

      it 'should raise an error when not given a hash, symbol, or string' do
        begin
          config.merge(100)
        rescue RuntimeError => e
          e.message.must_equal("Invalid data source: 100")
        end
      end

      it 'should not require an initial source to have been `#load`ed' do
        config.merge({ :a => 'a' })
        config.to_h.must_equal({ :a => 'a' })
      end

      it 'should mutate `@data`' do
        config.load({ :foo => 'original' })
        config.merge({ :foo => 'new' })
        config.to_h.must_equal({ :foo => 'new' })
      end

      it 'should merge all data if no namespace given' do
        config.load({ :a => 'a'})
        config.merge({ :a => 'a', :b => 'b' })
        config.to_h.must_equal({ :a => 'a', :b => 'b' })
      end

      it 'should merge namespaced data if namespace given' do
        config.load({ :a => 'a' })
        config.merge({ :foo => { :a => 'new a' }, :b => 'b' }, :foo)
        config.to_h.must_equal({ :a => 'new a' })
      end

      it 'should raise a KeyError if the given namespace is not found' do
        proc do
          config.merge({ :a => 'a', :foo => { :b => 'b'} }, :bar)
        end.must_raise(KeyError)
      end

      it 'should perform a deep merge' do
        h1 = { :a => true, :b => { :c => [1, 2, 3] } }
        h2 = { :a => false, :b => { :x => [3, 4, 5] } }

        config.load(h1)
        config.merge(h2)
        config.to_h.must_equal({
          :a => false,
          :b => {
            :c => [1, 2, 3],
            :x => [3, 4, 5]
          }
        })
      end

      it 'should define acessors on `@data`' do
        config.merge({ :a => 'a' })
        config.to_h.singleton_methods.must_include(:a)
        config.to_h.singleton_methods.must_include(:a=)
      end

      it 'should define accessors on the class' do
        config.merge({ :a => 'a' })
        config.singleton_methods.must_include(:a)
        config.singleton_methods.must_include(:a=)
      end

      it 'should return a Hash instance' do
        config.merge({}).must_be_instance_of(Hash)
      end

      it 'should return the result of calling #to_h after the merge' do
        config.load({ :a => 'a' })
        merge_result = config.merge({ :b => 'b' })
        merge_result.must_equal(config.to_h)
      end
    end

    describe '#[]' do
      it 'should delegate to `@data`' do
        config.load({ :a => 'a' })
        config[:a].must_equal(config.instance_variable_get(:@data)[:a])
        config[:b].must_equal(config.instance_variable_get(:@data)[:b])
      end
    end

    describe '#[]=' do
      it 'should add the key value pair to `@data`' do
        config[:a] = 'a'
        config.instance_variable_get(:@data)[:a].must_equal('a')
      end

      it 'should define acessors on `@data` for the given key' do
        config[:a] = 'a'
        config.instance_variable_get(:@data).singleton_methods.must_include(:a)
        config.instance_variable_get(:@data).singleton_methods.must_include(:a=)
      end

      it 'should define accessors on the class for the given key' do
        config[:a] = 'a'
        config.singleton_methods.must_include(:a)
        config.singleton_methods.must_include(:a=)
      end

      it 'should define accessors on set values' do
        config[:a] = { :foo => 'foo value' }
        config.a.singleton_methods.must_include(:foo)
        config.a.foo.must_equal('foo value')
      end

      it 'should delegate to `@data`' do
        config.load({ :a => 'a' })
        (config[:a] = 'new a').must_equal(config.instance_variable_get(:@data)[:a] = 'new a')
        (config[:b] = 'b').must_equal(config.instance_variable_get(:@data)[:b] = 'b')
      end

      it 'should return the set value' do
        config.send(:[]=, :a, 'a').must_equal('a')
      end
    end
  end
end
