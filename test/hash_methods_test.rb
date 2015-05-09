require_relative 'test_helper'

class HashMethodsTest < Minitest::Spec
  describe Accessible::HashMethods do
    describe '#each_hash' do
      it 'should execute the block on the given value if it is a hash' do
        begin
          Accessible::HashMethods.each_hash({}) do |hash|
            raise(hash.to_s)
          end
        rescue RuntimeError => e
          e.message.must_equal('{}')
        end
      end

      it 'should recursively execute the block on hashes nested in arrays' do
        begin
          Accessible::HashMethods.each_hash([{}]) do |hash|
            raise(hash.to_s)
          end
        rescue RuntimeError => e
          e.message.must_equal('{}')
        end
      end

      it 'should not pass non-hash values to the block' do
        raise_if_executed = proc { raise('block was excuted') }
        Accessible::HashMethods.each_hash('foo', &raise_if_executed)
        Accessible::HashMethods.each_hash(:foo, &raise_if_executed)
        Accessible::HashMethods.each_hash(100, &raise_if_executed)
        Accessible::HashMethods.each_hash(nil, &raise_if_executed)
        Accessible::HashMethods.each_hash(true, &raise_if_executed)
        Accessible::HashMethods.each_hash([], &raise_if_executed)
        Accessible::HashMethods.each_hash(proc{}, &raise_if_executed)
        Accessible::HashMethods.each_hash(Accessible, &raise_if_executed)
      end

      it 'should return the value it was given' do
        result = Accessible::HashMethods.each_hash({ :a => 'a' }) { :foo }
        result.must_equal({ :a => 'a' })
      end
    end

    describe '#deep_merge' do
      it 'should merge neseted hashes' do
        hash_1 = { :a => false, :b => "b", :c => { :c1 => "c1", :c2 => "c2", :c3 => { :d1 => "d1" } } }
        hash_2 = { :a => 1, :c => { :c1 => 2, :c3 => { :d2 => "d2" } } }
        expected = { :a => 1, :b => "b", :c => { :c1 => 2, :c2 => "c2", :c3 => { :d1 => "d1", :d2 => "d2" } } }

        Accessible::HashMethods.deep_merge(hash_1, hash_2).must_equal(expected)
      end
    end

    describe '#symbolize_keys' do
      it 'should' do
        skip('pending')
      end
    end
  end
end
