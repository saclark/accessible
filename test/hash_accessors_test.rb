require_relative 'test_helper'

class HashAccessorsTest < Minitest::Spec
  describe Accessible::HashAccessors do
    describe '#accessorize' do
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
        Accessible::HashAccessors.accessorize(@hash)
        @hash.complex.must_equal(@hash[:complex])
        @hash.complex.nested.array.must_equal(@hash[:complex][:nested][:array])
        @hash.complex.nested.array[0].hash_0.must_equal('hash_0 value')
        @hash.complex.nested.array[1].hash_1[0].inner.must_equal('inner value')
      end

      it 'should recursively define setters on the hash for every key' do
        Accessible::HashAccessors.accessorize(@hash)
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
        Accessible::HashAccessors.accessorize(data)
        data.languages.ruby.typed.must_equal('dynamic')
        data.languages.haskell.typed.must_equal('static')
      end

      it 'should allow non-standard or complex method names' do
        data = { 'key with spaces' => 'key with spaces value' }
        Accessible::HashAccessors.accessorize(data)
        data.must_respond_to(:"key with spaces")
      end

      it 'should override conflicting methods' do
        hash = { :class => 'overwritten' }
        Accessible::HashAccessors.accessorize(hash)
        hash.class.must_equal('overwritten')
      end
    end

    describe '#define_getter' do
      it 'should define a getter for the given key' do
        hash = { :foo => 'foo value' }
        Accessible::HashAccessors.define_getter(hash, :foo)
        hash.foo.must_equal('foo value')
      end

      it 'should define a getter only on the instance' do
        hash = { :foo => 'foo value' }
        Accessible::HashAccessors.define_getter(hash, :foo)
        {}.wont_respond_to(:foo)
      end

      it 'should be the same as calling :fetch on the hash with the same key' do
        hash = { :foo => 'foo value'}

        Accessible::HashAccessors.define_getter(hash, :foo)
        (hash.fetch(:foo)).must_equal(hash.foo)

        hash.delete(:foo)
        proc { hash.foo }.must_raise(KeyError)
      end
    end

    describe '#define_setter' do
      it 'should define a setter for the given key' do
        hash = { :foo => 'foo value' }
        Accessible::HashAccessors.define_setter(hash, :foo)
        hash.foo = 'new foo value'
        hash[:foo].must_equal('new foo value')
      end

      it 'should define a setter only on the instance' do
        hash = { :foo => 'foo value' }
        Accessible::HashAccessors.define_setter(hash, :foo)
        {}.wont_respond_to(:foo=)
      end

      it 'should define accessors on set values' do
        hash = { :foo => 'foo value' }
        Accessible::HashAccessors.define_setter(hash, :foo)
        hash.foo = { :new_value => 'new value' }

        hash[:foo].must_respond_to(:new_value)
        hash[:foo].must_respond_to(:new_value=)
      end

      it 'should be the same as calling :[]= with the same key and value' do
        hash = { :foo => 'foo value'}

        Accessible::HashAccessors.define_setter(hash, :foo)
        (hash.foo = 'new foo value').must_equal(hash[:foo] = 'new foo value')

        Accessible::HashAccessors.define_setter(hash, :bar)
        hash.bar = 'bar'
        hash[:bar].must_equal('bar')
      end
    end

    describe '#each_hash' do
      it 'should execute the block on the given value if it is a hash' do
        begin
          Accessible::HashAccessors.each_hash({}) do |hash|
            raise(hash.to_s)
          end
        rescue RuntimeError => e
          e.message.must_equal('{}')
        end
      end

      it 'should recursively execute the block on hashes nested in arrays' do
        begin
          Accessible::HashAccessors.each_hash([{}]) do |hash|
            raise(hash.to_s)
          end
        rescue RuntimeError => e
          e.message.must_equal('{}')
        end
      end

      it 'should not pass non-hash values to the block' do
        raise_if_executed = proc { raise('block was excuted') }
        class SubclassedHash < Hash; end
        Accessible::HashAccessors.each_hash('foo', &raise_if_executed)
        Accessible::HashAccessors.each_hash(:foo, &raise_if_executed)
        Accessible::HashAccessors.each_hash(100, &raise_if_executed)
        Accessible::HashAccessors.each_hash(nil, &raise_if_executed)
        Accessible::HashAccessors.each_hash(true, &raise_if_executed)
        Accessible::HashAccessors.each_hash([], &raise_if_executed)
        Accessible::HashAccessors.each_hash(proc{}, &raise_if_executed)
        Accessible::HashAccessors.each_hash(Accessible, &raise_if_executed)
      end

      it 'should return the value it was given' do
        result = Accessible::HashAccessors.each_hash({ :a => 'a' }) { :foo }
        result.must_equal({ :a => 'a' })
      end
    end
  end
end
