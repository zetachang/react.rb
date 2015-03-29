require "execjs"
require "sprockets"
require "sprockets/es6"

module ExecJS
  class Runtime
    alias_method :orig_compile, :compile
    def compile(source)
      context = orig_compile("var console = {error: function(){}, log: function(){}, warn: function(){}, info: function(){}};" + source)
      context
    end
  end
end

Sprockets.register_mime_type 'text/jsx', extensions: ['.jsx']
Sprockets.register_transformer 'text/jsx', 'application/javascript', Sprockets::ES6.new('whitelist' => ['react'])
