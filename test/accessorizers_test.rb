require_relative 'test_helper'

class AccessorizersTest < Minitest::Spec
  describe Accessible::Accessorizers do
    let(:obj) do
      Class.new do
        def self.to_h
          @data
        end

        def self.to_h=(data)
          @data = data
        end
      end
    end

    describe '#accessorize_data' do
      before do
        @hash = {
          :complex => {
            :nested => {
              :array => [
                { :hash_0 => 'hash_0 value' },
                { :hash_1 => [ { :inner => 'inner value' } ] }
              ]
            }
          }
        }
      end

      it 'should recursively define getters on the hash for every key' do
        Accessible::Accessorizers.accessorize_data(@hash)
        @hash.complex.must_equal(@hash[:complex])
        @hash.complex.nested.array.must_equal(@hash[:complex][:nested][:array])
        @hash.complex.nested.array[0].hash_0.must_equal('hash_0 value')
        @hash.complex.nested.array[1].hash_1[0].inner.must_equal('inner value')
      end

      it 'should recursively define setters on the hash for every key' do
        Accessible::Accessorizers.accessorize_data(@hash)
        @hash.complex.nested.array[1].hash_1[0].inner = 'new inner value'
        @hash.complex.nested.array[1].hash_1[0].inner.must_equal('new inner value')
        @hash.complex = 'new value'
        @hash.complex.must_equal('new value')
      end

      it 'should distinguish nested keys' do
        data = {
          :languages => {
            :ruby => {
              :typed => 'dynamic'
            },
            :haskell => {
              :typed => 'static'
            }
          }
        }
        Accessible::Accessorizers.accessorize_data(data)
        data.languages.ruby.typed.must_equal('dynamic')
        data.languages.haskell.typed.must_equal('static')
      end

      it 'should allow non-standard or complex method names' do
        data = { 'key with spaces' => 'key with spaces value' }
        Accessible::Accessorizers.accessorize_data(data)
        data.must_respond_to(:"key with spaces")
      end

      it 'should override conflicting methods' do
        hash = { :class => 'overwritten' }
        Accessible::Accessorizers.accessorize_data(hash)
        hash.class.must_equal('overwritten')
      end
    end

    describe '#accessorize_obj' do
      it 'should define getters on the class for all first tier keys' do
        obj.to_h = { :a => { :b => 'b' }, :c => 'c' }
        Accessible::Accessorizers.accessorize_obj(obj)
        obj.a.must_equal({ :b => 'b' })
        obj.c.must_equal('c')
        obj.wont_respond_to(:b)
      end

      it 'should define getters equivalent to calling `:fetch` on `@data` with the same key' do
        obj.to_h = { :foo => 'foo value'}
        Accessible::Accessorizers.accessorize_obj(obj)
        (obj.to_h.fetch(:foo)).must_equal(obj.foo)

        obj.to_h.delete(:foo)
        proc { obj.foo }.must_raise(KeyError)
      end

      it 'should define setters on the class for all first tier keys' do
        obj.to_h = { :a => { :b => 'b' }, :c => 'c' }
        Accessible::Accessorizers.accessorize_obj(obj)

        obj.a = 'new a value'
        obj.a.must_equal('new a value')

        obj.c = 'new c value'
        obj.c.must_equal('new c value')

        obj.wont_respond_to(:b=)
      end

      it 'should define accessors on values set after initial load' do
        obj.to_h = { :foo => 'foo value' }
        Accessible::Accessorizers.accessorize_obj(obj)
        obj.foo = { :new_value => 'new value' }

        obj.to_h[:foo].must_respond_to(:new_value)
        obj.to_h[:foo].must_respond_to(:new_value=)
      end

      it 'should define setters equivalent using `:[]=`' do
        obj.to_h = { :foo => 'foo value' }
        Accessible::Accessorizers.accessorize_obj(obj)

        (obj.foo = 'new foo value').must_equal(obj.to_h[:foo] = 'new foo value')

        obj.to_h.delete(:foo)
        obj.foo = 'restored foo'
        obj.foo.must_equal('restored foo')
      end

      it 'should raise an error if the object does not respond to `:to_h`' do
        proc { Accessible::Accessorizers.accessorize_obj(:foo) }.must_raise(NotImplementedError)

        begin
          Accessible::Accessorizers.accessorize_obj(:foo)
        rescue NotImplementedError => e
          e.message.must_equal("Expected `foo` to respond to `:to_h`")
        end
      end
    end

    describe '#define_accessors' do
      it 'should' do
        skip('pending')
      end
    end

    describe '#define_getter' do
      it 'should define a getter for the given key' do
        hash = { :foo => 'foo value' }
        Accessible::Accessorizers.define_getter(hash, :foo)
        hash.foo.must_equal('foo value')
      end

      it 'should define a getter only on the instance' do
        hash = { :foo => 'foo value' }
        Accessible::Accessorizers.define_getter(hash, :foo)
        {}.wont_respond_to(:foo)
      end

      it 'should be the same as calling :fetch on the hash with the same key' do
        hash = { :foo => 'foo value'}

        Accessible::Accessorizers.define_getter(hash, :foo)
        (hash.fetch(:foo)).must_equal(hash.foo)

        hash.delete(:foo)
        proc { hash.foo }.must_raise(KeyError)
      end
    end

    describe '#define_setter' do
      it 'should define a setter for the given key' do
        hash = { :foo => 'foo value' }
        Accessible::Accessorizers.define_setter(hash, :foo)
        hash.foo = 'new foo value'
        hash[:foo].must_equal('new foo value')
      end

      it 'should define a setter only on the instance' do
        hash = { :foo => 'foo value' }
        Accessible::Accessorizers.define_setter(hash, :foo)
        {}.wont_respond_to(:foo=)
      end

      it 'should define accessors on set values' do
        hash = { :foo => 'foo value' }
        Accessible::Accessorizers.define_setter(hash, :foo)
        hash.foo = { :new_value => 'new value' }

        hash[:foo].must_respond_to(:new_value)
        hash[:foo].must_respond_to(:new_value=)
      end

      it 'should be the same as calling :[]= with the same key and value' do
        hash = { :foo => 'foo value'}

        Accessible::Accessorizers.define_setter(hash, :foo)
        (hash.foo = 'new foo value').must_equal(hash[:foo] = 'new foo value')

        Accessible::Accessorizers.define_setter(hash, :bar)
        hash.bar = 'bar'
        hash[:bar].must_equal('bar')
      end
    end
  end
end
