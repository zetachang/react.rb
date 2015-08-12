module React
  
  module IsomorphicHelpers
    
    def self.included(base)
      base.extend(ClassMethods)
    end
    
    if RUBY_ENGINE != 'opal'
      
      def self.load_context(ctx, controller)
        @context = Context.new("#{controller.object_id}-#{Time.now.to_i}", ctx, controller) 
      end

    else
      
      def self.load_context(unique_id = nil)  # can be called on the client to force re-initialization for testing purposes
        @context = Context.new(unique_id) if on_opal_client? or !@context or @context.unique_id != unique_id
        @context
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
    
    def on_opal_server?
      IsomorphicHelpers.on_opal_server?
    end
    
    def on_opal_client?
      IsomorphicHelpers.on_opal_client?
    end
      
    def self.prerender_footers
      footer = Context.prerender_footer_blocks.collect { |block| block.call }.join("\n")
      footer = (footer + "#{@context.send_to_opal(:prerender_footers)}").html_safe if RUBY_ENGINE != 'opal' 
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
      
      def initialize(unique_id, ctx = nil, controller = nil)
        if RUBY_ENGINE != 'opal' 
          @controller = controller
          @ctx = ctx 
          ctx["ServerSideIsomorphicMethods"] = self
          send_to_opal(:load_context, unique_id)
        end
        self.class.before_first_mount_blocks.each { |block| block.call } 
      end
      
      def send_to_opal(method, *args)
        args = [1] if args.length == 0
        if @ctx
          unless @ctx.eval('Opal.React')
            @ctx.eval(Opal::Processor.load_asset_code(::Rails.application.assets, 'components')) rescue nil
            raise "No opal-react components found in the components.rb file" unless @ctx.eval('Opal.React')
          end
          @ctx.eval("Opal.React.IsomorphicHelpers.$#{method}(#{args.join(', ')})")
        end
      end
      
      def self.register_before_first_mount_block(&block)
        before_first_mount_blocks << block
        yield if IsomorphicHelpers.on_opal_client? 
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