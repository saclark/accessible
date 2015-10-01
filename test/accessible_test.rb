require_relative 'test_helper'

class AccessibleTest < Minitest::Spec
  describe Accessible do
    before do
      @expected_class_methods = Accessible::ClassMethods.public_instance_methods
    end

    describe '#included' do
      it 'should extended the including class with `ClassMethods`' do
        IncludedTest = Class.new { include Accessible }
        @expected_class_methods.each do |method|
          IncludedTest.must_respond_to(method)
        end
      end
    end

    describe '#create' do
      it 'should return a `Class` instance extended with `ClassMethods`' do
        CreateTestConst1 = Accessible.create
        CreateTestConst1.must_be_instance_of(Class)
        @expected_class_methods.each do |method|
          CreateTestConst1.must_respond_to(method)
        end
      end

      it 'should yield the extended `Class` instance to a block if given' do
        Accessible.create do |klass|
          klass.name.must_be_nil
          klass.must_be_instance_of(Class)
          @expected_class_methods.each do |method|
            klass.must_respond_to(method)
          end
        end
      end
    end
  end
end
