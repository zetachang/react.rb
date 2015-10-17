module React
  module IsomorphicHelpers
    def self.included(base)
      base.extend(ClassMethods)
    end

    if RUBY_ENGINE != 'opal'
      def self.load_context(ctx, controller, name = nil)
        puts "************************** React Server Context Initialized #{name} *********************************************"
        @context = Context.new("#{controller.object_id}-#{Time.now.to_i}", ctx, controller, name)
      end
    else
      def self.load_context(unique_id = nil, name = nil)
        # can be called on the client to force re-initialization for testing purposes
        if !unique_id or !@context or @context.unique_id != unique_id
          if on_opal_server?
            message = "************************ React Prerendering Context Initialized #{name} ***********************"
          else
            message = "************************ React Browser Context Initialized ****************************"
          end
          log(message)
          @context = Context.new(unique_id)
        end
        @context
      end
    end

    def self.log(message, message_type = :info)
      message = [message] unless message.is_a? Array
      if message_type == :info
        if on_opal_server?
          style = 'background: #00FFFF; color: red'
        else
          style = 'background: #222; color: #bada55'
        end
        message = ["%c" + message[0], style]+message[1..-1]
        `console.log.apply(console, message)`
      elsif message_type == :warning
        `console.warn.apply(console, message)`
      else
        `console.error.apply(console, message)`
      end
    end

    if RUBY_ENGINE != 'opal'
      def self.on_opal_server?
        false
      end

      def self.on_opal_client?
        false
      end
    else
      def self.on_opal_server?
        `typeof window.document === 'undefined'`
      end

      def self.on_opal_client?
        !on_opal_server?
      end
    end

    def log(*args)
      IsomorphicHelpers.log(*args)
    end

    def on_opal_server?
      self.class.on_opal_server?
    end

    def on_opal_client?
      self.class.on_opal_client?
    end

    def self.prerender_footers
      footer = Context.prerender_footer_blocks.collect { |block| block.call }.join("\n")
      if RUBY_ENGINE != 'opal'
        footer = (footer + "#{@context.send_to_opal(:prerender_footers)}") if @context
        footer = footer.html_safe
      end
      footer
    end

    class Context
      attr_reader :controller
      attr_reader :unique_id

      def self.before_first_mount_blocks
        @before_first_mount_blocks ||= []
      end

      def self.prerender_footer_blocks
        @prerender_footer_blocks ||= []
      end

      def initialize(unique_id, ctx = nil, controller = nil, name = nil)
        @unique_id = unique_id
        if RUBY_ENGINE != 'opal'
          @controller = controller
          @ctx = ctx
          ctx["ServerSideIsomorphicMethods"] = self
          send_to_opal(:load_context, @unique_id, name)
        end
        self.class.before_first_mount_blocks.each { |block| block.call(self) }
      end

      def eval(js)
        @ctx.eval(js) if @ctx
      end

      def send_to_opal(method, *args)
        return unless @ctx
        args = [1] if args.length == 0
        ::ReactiveRuby::ComponentLoader.new(@ctx).load!
        @ctx.eval("Opal.React.IsomorphicHelpers.$#{method}(#{args.collect { |arg| "'#{arg}'"}.join(', ')})")
      end

      def self.register_before_first_mount_block(&block)
        before_first_mount_blocks << block
      end

      def self.register_prerender_footer_block(&block)
        prerender_footer_blocks << block
      end
    end

    class IsomorphicProcCall
      def result
        @result.first if @result
      end

      def initialize(name, block, *args)
        @name = name
        block.call(self, *args)
        @result ||= send_to_server(*args) if IsomorphicHelpers.on_opal_server?
      end

      def when_on_client(&block)
        @result = [block.call] if IsomorphicHelpers.on_opal_client?
      end

      def send_to_server(*args)
        if IsomorphicHelpers.on_opal_server?
          args_as_json = args.to_json
          @result = [JSON.parse(`window.ServerSideIsomorphicMethods[#{@name}](#{args_as_json})`)]
        end
      end

      def when_on_server(&block)
        @result = [block.call.to_json] unless IsomorphicHelpers.on_opal_client? or IsomorphicHelpers.on_opal_server?
      end
    end

    module ClassMethods
      def on_opal_server?
        IsomorphicHelpers.on_opal_server?
      end

      def on_opal_client?
        IsomorphicHelpers.on_opal_client?
      end

      def log(*args)
        IsomorphicHelpers.log(*args)
      end

      def controller
        IsomorphicHelpers.context.controller
      end

      def before_first_mount(&block)
        React::IsomorphicHelpers::Context.register_before_first_mount_block &block
      end

      def prerender_footer(&block)
        React::IsomorphicHelpers::Context.register_prerender_footer_block &block
      end

      if RUBY_ENGINE != 'opal'
        def isomorphic_method(name, &block)
          React::IsomorphicHelpers::Context.send(:define_method, name) do |args_as_json|
            React::IsomorphicHelpers::IsomorphicProcCall.new(name, block, *JSON.parse(args_as_json)).result
          end
        end
      else
        require 'json'

        def isomorphic_method(name, &block)
          self.class.send(:define_method, name) do | *args |
            React::IsomorphicHelpers::IsomorphicProcCall.new(name, block, *args).result
          end
        end
      end
    end
  end
end
