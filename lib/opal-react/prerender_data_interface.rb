module React
  
  class PrerenderDataInterface
        
    attr_reader :while_loading_counter
    
    class << self
      
      def get_next_while_loading_counter(i)
        PrerenderDataInterface.load!.get_next_while_loading_counter(i)
      end
      
      ["preload_css", "css_to_preload!", "cookie"].each do |method_name|
        define_method(method_name) do |*args| 
          PrerenderDataInterface.load!.send(method_name, *args)
        end
      end
      
      def load!
        (@instance ||= new)
      end
      
      def on_opal_server?
        RUBY_ENGINE == 'opal' and !(`typeof window.ServerSidePrerenderDataInterface === 'undefined'`)
      end

      def on_opal_client?
        RUBY_ENGINE == 'opal' and `typeof window.ServerSidePrerenderDataInterface === 'undefined'`
      end
      
    end
        
    def on_opal_server?
      PrerenderDataInterface.on_opal_server?
    end
    
    def on_opal_client?
      PrerenderDataInterface.on_opal_client?
    end
    
    def initialize(controller = nil)
      require 'opal-jquery' if RUBY_ENGINE == 'opal' and `typeof window.ServerSidePrerenderDataInterface === 'undefined'`
      @controller = controller
      @css_to_preload = ""
      @while_loading_counter = `ClientSidePrerenderDataInterface.InitialWhileLoadingCounter` unless on_opal_server? rescue nil
      @while_loading_counter ||= 0
    end
    
    attr_accessor :initial_while_loading_counter
        
    def get_next_while_loading_counter(i)
      if on_opal_server?
        `window.ServerSidePrerenderDataInterface.get_next_while_loading_counter(1)`.to_i
      else
        # we are on the server and have been called by the opal side, OR we are the client both work the same
        @while_loading_counter += 1
      end
    end
    
    def preload_css(css)
      if on_opal_server?
        `window.ServerSidePrerenderDataInterface.preload_css(#{css})`
      elsif RUBY_ENGINE != 'opal'
        @css_to_preload << css << "\n"
      end
    end
    
    def css_to_preload!
      @css_to_preload.tap { @css_to_preload = "" }
    end
    
    def cookie(name)
      if @controller
        @controller.send(:cookies)[name]
      elsif on_opal_server?
        `window.ServerSidePrerenderDataInterface.cookie(#{name})`
      end
    end
    
    def generate_next_footer
      ("<style>\n#{css_to_preload!}\n</style>\n<script type='text/javascript'>\n"+
        "if (typeof window.ClientSidePrerenderDataInterface === 'undefined') { window.ClientSidePrerenderDataInterface = [] }\n"+
        "if (typeof window.ClientSidePrerenderDataInterface.InitialWhileLoadingCounter === 'undefined') { window.ClientSidePrerenderDataInterface.InitialWhileLoadingCounter = #{initial_while_loading_counter} }\n"+ 
        "</script>\n"
       ).html_safe
    end unless RUBY_ENGINE == 'opal'
    
  end

end
