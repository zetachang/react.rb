require "spec_helper"

if opal?
describe React::Validator do
  before do
    stub_const 'Foo', Class.new(React::Component::Base)
  end
  describe '#validate' do
    describe "Presence validation" do
      it "should check if required props provided" do
        validator = React::Validator.new(Foo).build do
          requires :foo
          requires :bar
        end

        expect(validator.validate({})).to eq(["Required prop `foo` was not specified", "Required prop `bar` was not specified"])
        expect(validator.validate({foo: 1, bar: 3})).to eq([])
      end

      it "should check if passed non specified prop" do
        validator = React::Validator.new(Foo).build do
          optional :foo
        end

        expect(validator.validate({bar: 10})).to eq(["Provided prop `bar` not specified in spec"])
        expect(validator.validate({foo: 10})).to eq([])
      end
    end

    describe "Type validation" do
      it "should check if passed value with wrong type" do
        validator = React::Validator.new(Foo).build do
          requires :foo, type: String
        end

        expect(validator.validate({foo: 10})).to eq(["Provided prop `foo` could not be converted to String"])
        expect(validator.validate({foo: "10"})).to eq([])
      end

      it "should check if passed value with wrong custom type" do
        stub_const 'Bar', Class.new
        validator = React::Validator.new(Foo).build do
          requires :foo, type: Bar
        end

        expect(validator.validate({foo: 10})).to eq(["Provided prop `foo` could not be converted to Bar"])
        expect(validator.validate({foo: Bar.new})).to eq([])
      end

      it 'coerces native JS prop types to opal objects' do
        validator = React::Validator.new(Foo).build do
          requires :foo, type: `{ x: 1 }`
        end

        message = "Provided prop `foo` could not be converted to [object Object]"
        expect(validator.validate({foo: `{ x: 1 }`})).to eq([message])
      end

      it 'coerces native JS values to opal objects' do
        validator = React::Validator.new(Foo).build do
          requires :foo, type: Array[Fixnum]
        end

        message = "Provided prop `foo`[0] could not be converted to Numeric"
        expect(validator.validate({foo: `[ { x: 1 } ]`})).to eq([message])
      end

      it "should support Array[Class] validation" do
        validator = React::Validator.new(Foo).build do
          requires :foo, type: Array[Hash]
        end

        expect(validator.validate({foo: [1,'2',3]})).to eq(
          [
            "Provided prop `foo`[0] could not be converted to Hash",
            "Provided prop `foo`[1] could not be converted to Hash",
            "Provided prop `foo`[2] could not be converted to Hash"
          ]
        )
        expect(validator.validate({foo: [{},{},{}]})).to eq([])
      end
    end

    describe "Limited values" do
      it "should check if passed value is not one of the specified values" do
        validator = React::Validator.new(Foo).build do
          requires :foo, values: [4,5,6]
        end

        expect(validator.validate({foo: 3})).to eq(["Value `3` for prop `foo` is not an allowed value"])
        expect(validator.validate({foo: 4})).to eq([])
      end
    end
  end

  describe '#undefined_props' do
    let(:props) { { foo: 'foo', bar: 'bar', biz: 'biz', baz: 'baz' } }
    let(:validator) do
      React::Validator.new(Foo).build do
        requires :foo
        optional :bar
      end
    end

    it 'slurps up any extra params into a hash' do
      others = validator.undefined_props(props)
      expect(others).to eq({ biz: 'biz', baz: 'baz' })
    end

    it 'prevents validate non-specified params' do
      validator.undefined_props(props)
      expect(validator.validate(props)).to eq([])
    end
  end

  describe "default_props" do
    it "should return specified default values" do
      validator = React::Validator.new(Foo).build do
        requires :foo, default: 10
        requires :bar
        optional :lorem, default: 20
      end

      expect(validator.default_props).to eq({foo: 10, lorem: 20})
    end
  end
end
end
