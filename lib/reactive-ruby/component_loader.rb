module ReactiveRuby
  class ComponentLoader
    attr_reader :v8_context
    private :v8_context

    def initialize(v8_context)
      unless v8_context
        raise ArgumentError.new('Could not obtain ExecJS runtime context')
      end
      @v8_context = v8_context
    end

    def load(file = components)
      return true if loaded?
      !!v8_context.eval(opal(file))
    end

    def load!(file = components)
      return true if loaded?
      self.load(file)
    ensure
      raise "No react.rb components found in #{components}.rb" unless loaded?
    end

    def loaded?
      !!v8_context.eval('Opal.React')
    end

    private

    def components
      # Make this configurable at some point
      'components'
    end

    def opal(file)
      Opal::Processor.load_asset_code(assets, file)
    rescue # What exception is being caught here?
    end

    def assets
      ::Rails.application.assets
    end
  end
end
