module ReactiveRuby
  module ServerRendering
    class ContextualRenderer < React::ServerRendering::ExecJSRenderer
      def initialize(options = {})
        @replay_console = options.fetch(:replay_console, true)
        filenames = options.fetch(:files, ["react.js", "components.js"])
        js_code = CONSOLE_POLYFILL.dup

        filenames.each do |filename|
          js_code << ::Rails.application.assets[filename].to_s
        end

        super(options.merge(code: js_code))
      end

      def render(component_name, props, prerender_options)
        if prerender_options.is_a? Hash
          if ExecJS.runtime.name == "(V8)" and prerender_options[:context_initializer]
            raise React::ServerRendering::PrerenderError.new(component_name, props, "you must use 'therubyracer' with the prerender[:context] option") unless ExecJS.runtime.name == "(V8)"
          else
            prerender_options[:context_initializer].call @context.instance_variable_get("@v8_context")
            prerender_options = prerender_options[:static] ? :static : true
          end
        end
        #pass prerender: :static to use renderToStaticMarkup
        react_render_method = if prerender_options == :static
                                "renderToStaticMarkup"
                              else
                                "renderToString"
                              end

        if !props.is_a?(String)
          props = props.to_json
        end

        js_code = <<-JS
          (function () {
            var result = React.#{react_render_method}(React.createElement(#{component_name}, #{props}));
        #{@replay_console ? CONSOLE_REPLAY : ""}
            return result;
          })()
        JS

        @context.eval(js_code).html_safe
      rescue ExecJS::ProgramError => err
        raise React::ServerRendering::PrerenderError.new(component_name, props, err)
      end

      def after_render(component_name, props, prerender_options)
        @replay_console ? CONSOLE_REPLAY : ""
      end

      # Reimplement console methods for replaying on the client
      CONSOLE_POLYFILL = <<-JS
        var console = { history: [] };
        ['error', 'log', 'info', 'warn'].forEach(function (fn) {
          console[fn] = function () {
            console.history.push({level: fn, arguments: Array.prototype.slice.call(arguments)});
          };
        });
      JS

      # Replay message from console history
      CONSOLE_REPLAY = <<-JS
        (function (history) {
          if (history && history.length > 0) {
            result += '\\n<scr'+'ipt>';
            history.forEach(function (msg) {
              result += '\\nconsole.' + msg.level + '.apply(console, ' + JSON.stringify(msg.arguments) + ');';
            });
            result += '\\n</scr'+'ipt>';
          }
        })(console.history);
      JS
    end
  end
end
