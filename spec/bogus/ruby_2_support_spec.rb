require 'spec_helper'

if RUBY_VERSION >= '2.0'
  describe "Ruby 2.0 keyword arguments" do
    class ExampleForKeywordArgs
      eval "def foo(x: raise, y: 1); end"
      eval "def bar(x: 1, **rest); end"
    end

    include Bogus::MockingDSL

    shared_examples_for "stubbing methods with keyword arguments" do
      it "can spy on stubbed methods" do
        stub(subject).foo(any_args)

        subject.foo(x: "test")

        expect(subject).to have_received.foo(x: "test")
        expect(subject).to_not have_received.foo(x: "baz")
      end

      it "can mock methods with keyword arguments" do
        mock(subject).foo(x: 1) { :return }

        expect(subject.foo(x: 1)).to eq :return

        expect { Bogus.after_each_test }.not_to raise_error
      end

      it "can stub methods with keyword arguments" do
        stub(subject).foo(x: "bar") { :return_value }

        expect(subject.foo(x: "bar")).to eq :return_value
      end

      it "raises on error on unknown keyword" do
        expect {
          stub(subject).foo(x: "bar", baz: "baz")
        }.to raise_error(ArgumentError)
      end

      it "does not overwrite the method signature" do
        stub(subject).foo(x: 1)

        expect {
          subject.foo(bar: 1)
        }.to raise_error(ArgumentError)
      end
    end

    shared_examples_for "stubbing methods with double splat" do
      it "can spy on stubbed methods" do
        stub(subject).bar(any_args)

        subject.bar(x: "test", z: "spec")

        expect(subject).to have_received.bar(x: "test", z: "spec")
        expect(subject).to_not have_received.bar(y: "baz")
      end

      it "can mock methods with keyword arguments" do
        mock(subject).bar(x: 1, z: 2) { :return }

        expect(subject.bar(x: 1, z: 2)).to eq :return

        expect { Bogus.after_each_test }.not_to raise_error
      end

      it "can stub methods with keyword arguments" do
        stub(subject).bar(x: "bar", z: "bar") { :return_value }

        expect(subject.bar(x: "bar", z: "bar")).to eq :return_value
      end
    end

    context "with regular objects" do
      subject { ExampleForKeywordArgs.new }

      include_examples "stubbing methods with keyword arguments"
      include_examples "stubbing methods with double splat"
    end

    context "with fakes" do
      subject { fake(:example_for_keyword_args) }

      it "allows spying without stubbing" do
        subject.foo(x: "test")

        expect(subject).to have_received.foo(x: "test")
      end

      include_examples "stubbing methods with keyword arguments"
      include_examples "stubbing methods with double splat"
    end
  end
end
