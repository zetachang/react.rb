require 'spec_helper'

if ruby?
RSpec.describe ReactiveRuby::ComponentLoader do
  GLOBAL_WRAPPER = <<-JS
    var global = global || this;
    var self = self || this;
    var window = window || this;
  JS

  let(:js) { ::Rails.application.assets['components'].to_s }
  let(:context) { ExecJS.compile(GLOBAL_WRAPPER + js) }
  let(:v8_context) { context.instance_variable_get(:@v8_context) }

  describe '.new' do
    it 'raises a meaningful exception when initialized without a context' do
      expect {
        described_class.new(nil)
      }.to raise_error(/Could not obtain ExecJS runtime context/)
    end
  end

  describe '#load' do
    it 'loads given asset file into context' do
      loader = described_class.new(v8_context)

      expect {
        loader.load
      }.to change { !!v8_context.eval('Opal.React') }.from(false).to(true)
    end

    it 'is truthy upon successful load' do
      loader = described_class.new(v8_context)
      expect(loader.load).to be_truthy
    end

    it 'fails silently returning false' do
      loader = described_class.new(v8_context)
      expect(loader.load('foo')).to be_falsey
    end
  end

  describe '#load!' do
    it 'is truthy upon successful load' do
      loader = described_class.new(v8_context)
      expect(loader.load!).to be_truthy
    end

    it 'raises an expection if loading fails' do
      loader = described_class.new(v8_context)
      expect { loader.load!('foo') }.to raise_error(/No react\.rb components/)
    end
  end

  describe '#loaded?' do
    it 'is truthy if components file is already loaded' do
      loader = described_class.new(v8_context)
      loader.load
      expect(loader).to be_loaded
    end

    it 'is false if components file is not loaded' do
      loader = described_class.new(v8_context)
      expect(loader).to_not be_loaded
    end
  end
end
end
