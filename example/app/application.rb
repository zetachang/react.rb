# app/application.rb
require 'opal'
#require "opal-jquery"
require "views/index"
#require "react"

module Hooks
  def self.included(base)
    base.extend ClassMethods
  end
  
  module ClassMethods
    def before_mount
      instance_eval <<-CODE
        def callback
        end
      CODE
    end
    
    def define_hook(name)
      accessor_name = "_#{name}_callbacks"
      
      setup_hook_accessors(accessor_name)
      define_hook_writer(name, accessor_name)
    end
    
    private
      def define_hook_writer(hook, accessor_name)
        instance_eval <<-RUBY_EVAL
          def #{hook}(method=nil, &block)
            callback = block_given? ? block : method
            #{accessor_name} << callback
          end
        RUBY_EVAL
      end
      
      def setup_hook_accessors(accessor_name)
        #class_inheritable_array(accessor_name, :instance_writer => false)
        #send("#{accessor_name}=", [])
      end
      
  end
  
  # def run_hook(name, *args)
#     self.class.send("_#{name}_callbacks").each do |callback|
#       send(callback, *args) and next if callback.kind_of? Symbol
#       callback.call(*args)
#     end
#   end
end



class Cat
  include Hooks

  define_hook :before_dinner
  before_dinner :lorem
  
  def lorem
    puts "Before!"
  end
end

#cat = Cat.new
#cat.run_hook :before_dinner
  
#puts Uber::VERSION
# class MyHeader < React::Component
#   def render
#     React.create_element('h1') { "React.js on Ruby!" }
#     # should be something like
#     # h1 { "title" }
#     # h2 { "subtitle" }
#     # possible idea may be h1 & h2 will secretly append stuff to the returned result
#   end
# end
#
# Document.ready? do
#   React.render :my_header
# end